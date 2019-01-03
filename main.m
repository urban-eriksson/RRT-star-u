function main()

state = 'init';

while ~strcmp(state,'finito')
    
    if strcmp(state,'init') % Initialization
        rng(101)
        delete(timerfind)
        figure(1001);
        clf
        hold on
        axis([-100 900 -400 400])
        mapobject = Map();
        h_start = Sprite('CData',imread('start.png'),'Offset',[-16.5 -16.5],'Position',[350 0],'Scale',0.5);
        h_goal = Sprite('CData',imread('goal.png'),'Offset',[-16.5 -16.5],'Position',[700 0],'Scale',0.5);
        drone = Drone();
        drone.Sprite.Position = [350 0];
        rootnode = Node(drone.Sprite.Position, Node.empty, 0, plot([]));
        distance_per_step = 2;
        planning_radius = 100;
        planning_attempt = 1;
        goal_position = [700 0];
        state = 'plan';
    elseif strcmp(state,'plan') % Path planning
        if planning_attempt == 1
            if mapobject.collision_check([rootnode.Position; goal_position])
                goalcost = rootnode.preliminary_cost(goal_position);
                hgoal = plot([rootnode.Position(1) goal_position(1)],[rootnode.Position(2) goal_position(2)],'color',[0 1 0]);
                rootgoalnode = Node(goal_position, rootnode, goalcost, hgoal);
                rootgoalnode.IsGoalNode = true;
                rootnode.add_child(rootgoalnode);
            end
        else
            h_circle = Circle('Position',drone.Sprite.Position,'Radius', (planning_attempt-1)*planning_radius);
            drawnow
            %tic
            RRTstar_u(mapobject, rootnode, goal_position, planning_radius, planning_attempt);
            %toc
            delete(h_circle)
            drawnow
        end
        state = 'select';
    elseif strcmp(state,'select') % Selection of path
        bestgoal = rootnode.find_best_goalnode();
        if isempty(bestgoal)
            planning_attempt = planning_attempt + 1;
            state = 'plan';
        else
            planning_attempt = 1;
            path_nodes = bestgoal.backtrack_path();
            rootnode.prune_siblings(path_nodes(2));
            delta =  path_nodes(2).Position - rootnode.Position;
            distance = sqrt(sum(delta.^2));
            unit_vector = delta / distance;
            orientation = atan2(delta(2),delta(1));
            drone.Sprite.Orientation = orientation;
            state = 'travelling';
        end
    elseif strcmp(state,'travelling') % Moving along path
        % Check camera
        new_obstacle = drone.perform_camera_scan(mapobject);
        path_free = true;
        if new_obstacle
            path_free = mapobject.collision_check(reshape([path_nodes.Position],2,length(path_nodes))');
            rootnode.prune_tree(mapobject);
        end
        % If path to goal still free then continue, else go back to planning
        if path_free
            rootnode.Position = rootnode.Position + unit_vector * distance_per_step;
            drone.Sprite.Position = rootnode.Position;
            distance_to_waypoint = rootnode.distance(path_nodes(2).Position);
            pause(0.1)
            if distance_to_waypoint < distance_per_step
                state = 'reachedwaypoint';
            end
        else
            state = 'plan';
        end
    elseif strcmp(state,'reachedwaypoint') % Move to next node
        delete(rootnode);
        rootnode = path_nodes(2);
        drone.Sprite.Position = rootnode.Position;
        delete(rootnode.Line);
        rootnode.Parent = Node.empty;
        if rootnode.IsGoalNode
            state = 'finito';
        else
            state = 'select';
        end
    end
end

h = text(280,0,'Reached finish!','FontSize',24);
onoff = {'on','off'};
t = timer('Period', 0.1, 'ExecutionMode', 'fixedRate');
t.TimerFcn = @(~,~) set(h,'Visible',onoff{mod(floor(second(datetime)),2)+1});
start(t)
pause(6)
stop(t)
delete(t)
delete(drone)
delete(h)

 