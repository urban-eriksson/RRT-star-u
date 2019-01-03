classdef Map < handle
    
    properties
        Sprite, cdata, adata
    end
    
    methods
        
        function obj = Map()
            %[obj.cdata, ~, obj.adata] = imread('course3.png');
            obj.cdata = imread('course3.png');
            obj.Sprite = Sprite('CData',obj.cdata, 'Scale', 10, 'Position', [0 -285]);
        end
        
        function delete(obj)
            delete(obj.Sprite)
        end
        
        % Takes a path with several waypoints and checks for collision
        % Skips the first position where the drone is at
        function isfree = collision_check(this, positions)
            resolution = this.Sprite.Scale / 2;
            points = [];
            N = size(positions,1);
            for j = 1:N-1
                current_point = positions(j,:);
                delta = positions(j+1,:) - current_point;
                distance = sqrt(sum(delta.^2));
                unit_vector = delta / distance;
                while distance > resolution
                    current_point = current_point + resolution * unit_vector;
                    points = [points ; current_point];
                    delta = positions(j+1,:) - current_point;
                    distance = sqrt(sum(delta.^2));
                end
                points = [points ; positions(j+1,:)];
            end
            %points = [points; positions(N,:)];
            
            colors = this.Sprite.get_color(points);
            
            isfree = ~any(colors(:,1) == 0);
            
        end
    end
end