classdef Node < handle
    
    properties
        Position, Parent, Cost, Line, Children, IsGoalNode
    end
    
    methods
        
        function obj = Node(position, parent, cost, line_handle)
            obj.Position = position;
            obj.Parent = parent;
            obj.Cost = cost;
            obj.Line = line_handle;
            obj.Children = [];
            obj.IsGoalNode = false;
        end
        
        
        function [nearestnode, nearestdist2] = find_nearest(this, position)
            nearestnode = this;
            nearestdist2 = this.distance2(position);
            for j = 1:length(this.Children)
                if ~this.Children(j).IsGoalNode
                    [nodej,dist2j] = this.Children(j).find_nearest(position);
                    if dist2j < nearestdist2
                        nearestdist2 = dist2j;
                        nearestnode = nodej;
                    end
                end
            end
        end
        
        function [bestgoal, lowestcost] = find_best_goalnode(this)
            if this.IsGoalNode
               bestgoal = this;
               lowestcost = bestgoal.Cost;
            else
               lowestcost = inf;
               bestgoal = Node.empty;
               for j = 1:length(this.Children)
                    [bestgoalj, lowestcostj] = this.Children(j).find_best_goalnode();
                    if lowestcostj < lowestcost
                        lowestcost = lowestcostj;
                        bestgoal = bestgoalj;
                    end
                end
            end
        end
        
        function nodes = backtrack_path(this)
            nodes = this;
            parent_node = this.Parent;
            while ~isempty(parent_node)
                nodes = [parent_node nodes];
                parent_node = parent_node.Parent;
            end
        end
        
        function d = distance(this, position)
            d = sqrt((this.Position(1) - position(1))^2 + (this.Position(2) - position(2))^2);
        end

        function d = distance2(this, position)
            d = (this.Position(1) - position(1))^2 + (this.Position(2) - position(2))^2;
        end

        
        function nodes = find_inside(this, position, radius, nodes)
            if this.distance(position) <= radius
                nodes = [nodes this];
            end
            
            for j = 1:length(this.Children)
                nodes = this.Children(j).find_inside(position, radius, nodes);
            end
        end
        
        function prel_cost = preliminary_cost(this, position)
            prel_cost = this.Cost + this.distance(position);
        end
        
        function add_child(this,node)
            this.Children = [this.Children node];
        end
        
        % Just removes pointer to child
        function remove_child(this, node)
            newchildren = Node.empty;
            for j = 1:length(this.Children)
                if this.Children(j) ~= node
                    newchildren = [newchildren this.Children(j)];
                end
            end
            this.Children = newchildren;
        end
        
        function prune_siblings(this, node)
            for j = 1:length(this.Children)
                if this.Children(j) == node
                    remainingchild = node;
                else
                    this.remove_subtree(this.Children(j));
                end
            end
            this.Children = remainingchild;
        end
        
        function prune_tree(this,mapobject)
            newchildren = Node.empty;
            for j = 1:length(this.Children)
                isfree = mapobject.collision_check([this.Position; this.Children(j).Position]);
                if ~isfree
                    this.remove_subtree(this.Children(j))
                else
                    newchildren = [newchildren this.Children(j)];
                    this.Children(j).prune_tree(mapobject);
                end
            end
            this.Children = newchildren;
        end
        
        function remove_subtree(this,node)
            for j = 1:length(node.Children)
                this.remove_subtree(node.Children(j));
            end
            delete(node);
        end
        
        function delete(obj)
            delete(obj.Line)
        end
        
    end
end