function RRTstar_ux(mapobject, rootnode, goal_position,sampling_radius,planning_attempt)
    % Rapidly exploring random tree (RRT) animation
    % By Urban Eriksson
    
    eta=10;
    r_neighborhood = 30;
    %sampling_radius = 100;
    root_position = rootnode.Position;
    
    max_iter = 200;
    max_new_nodes = 100;
    new_nodes = 0;
    for j = 1:max_iter

        % Sample random configuration, this function is called starting
        % with the 2nd planning attempt
        [xrand, yrand] = radrand('Rmax', (planning_attempt-1) * sampling_radius, ...
            'Rmin', (planning_attempt-2) * sampling_radius); 
        rand_pos = [xrand yrand] + root_position;
        
        %  Find nearest
        [nearestnode, d2_nearest] = rootnode.find_nearest(rand_pos);
        
        if mapobject.collision_check([nearestnode.Position; rand_pos])
            
            % Limit the step towards the random position
            d_new = min(eta, sqrt(d2_nearest));
            k = d_new / sqrt(d2_nearest);
            new_pos = (1-k) * nearestnode.Position + k * rand_pos;

            % Find neighbors and the costs for coming to to new node through them   
            neighbors = rootnode.find_inside(new_pos,r_neighborhood,Node.empty);
            prel_costs = arrayfun( @(obj) obj.preliminary_cost(new_pos), neighbors );
            [~, sort_index] = sort(prel_costs);

            % Nearest parent not always give the lowest cost
            % therefore search among neighbors for the best parent
            foundparent = false;
            for k = 1:length(neighbors)
                if mapobject.collision_check([neighbors(sort_index(k)).Position; new_pos])
                    parent = neighbors(sort_index(k));
                    newcost = prel_costs(sort_index(k));
                    foundparent = true;
                    break
                end
            end
            
            if ~foundparent
                keyboard
            end
            
            % Create new node and add as a child to the selected parent
            h = plot([parent.Position(1) new_pos(1)],[parent.Position(2) new_pos(2)],'b');
            newnode = Node(new_pos, parent, newcost, h); 
            parent.add_child(newnode);

            % The rewiring of neighbors through the new node
            % 1. Define new parent for neighbor
            % 2. Add child for newnode
            % 3. Remove child for old Parent            
            for k = 1:length(neighbors)
                testcost = newcost + newnode.distance(neighbors(k).Position);
                if  testcost < neighbors(k).Cost
                    if mapobject.collision_check([newnode.Position; neighbors(k).Position])
                        neighbors(k).Parent.remove_child(neighbors(k));
                        neighbors(k).Parent = newnode;
                        neighbors(k).Cost = testcost;
                        delete(neighbors(k).Line);
                        neighbors(k).Line = plot([new_pos(1) neighbors(k).Position(1)],[new_pos(2) neighbors(k).Position(2)],'b');
                        newnode.add_child(neighbors(k));                        
                    end
                end
            end
            
            % Add a path straight to goal from new node if possible
            if mapobject.collision_check([newnode.Position; goal_position])
                goalcost = newnode.preliminary_cost(goal_position);
                hgoal = plot([newnode.Position(1) goal_position(1)],[newnode.Position(2) goal_position(2)],'color',[0 1 0]);
                newgoalnode = Node(goal_position, newnode, goalcost, hgoal);
                newgoalnode.IsGoalNode = true;
                newnode.add_child(newgoalnode);
            end
            
            new_nodes = new_nodes + 1;
            if new_nodes >= max_new_nodes
                break;
            end
        end
    end
end

   