classdef Drone < handle
    
    properties
        Sprite, sprite_number, toggler, cdata1, adata1, cdata2, adata2
    end
    
    methods
        
        function obj = Drone()
            [obj.cdata1, ~, obj.adata1] = imread('dronemini1f.png');
            obj.Sprite = Sprite('CData', obj.cdata1, 'AlphaData', obj.adata1);
            obj.Sprite.Offset = [-16.5 -36.5];
            [obj.cdata2, ~, obj.adata2] = imread('dronemini3f.png');
            obj.sprite_number = 1;
            obj.toggler = timer('Period', 0.5, 'ExecutionMode', 'fixedRate');
            obj.toggler.TimerFcn = @(~,~) obj.toggle_color_data();
            start(obj.toggler)
        end
        
        function found_new_obstacle = perform_camera_scan(this, mapobject)
            angles = [-pi/4 -pi/8 0 pi/8 pi/3];
            resolution = mapobject.Sprite.Scale / 2;
            found_new_obstacle = false;
            for j = 1:length(angles)
                % search rays x,y
                x = 8 + (1:10)'*resolution*cos(angles(j));
                y = (1:10)'*resolution*sin(angles(j));
                axis_coords = this.Sprite.get_axis_coordinates([x y]);
                colors = mapobject.Sprite.get_color(axis_coords);
                ix = find(colors(:,1)~=255,1);
                if ~isempty(ix)
                    if colors(ix,1) == 192
                        mapobject.Sprite.set_color(axis_coords(ix,:),[0 0 0]);
                        found_new_obstacle = true;
                    end
                end
            end
            %if found_new_obstacle
            %    mapobject.Sprite.update_color_data();
            %end
        end
        
        function delete(obj)
            stop(obj.toggler)
            delete(obj.toggler)
            delete(obj.Sprite)
        end
        
        function move(this)
           for j = 1:500
               this.Sprite.Position = [j j];
               tic
               %drawnow
               pause(0.04)
               toc
           end
            
        end
        
        
        function toggle_color_data(this)
            
            if this.sprite_number == 1
                this.sprite_number = 2;
                this.Sprite.set('CData', this.cdata2, 'AlphaData', this.adata2);
            else
                this.sprite_number = 1;
                this.Sprite.set('CData', this.cdata1, 'AlphaData', this.adata1);
            end
        end
    end
end
    