classdef Sprite < handle
%SPRITE Create 2D sprite
%   SPRITE('CData',cdata,'AlphaData',adata,...) creates a sprite in 2-D coordinates
%   
%   sprite('Position',pos) specifices the 2D translation of the sprite with
%   respect to the origin
%  
%   sprite('Offset',xy) Initallay the origin of the sprite is to the lower
%   left, and the sprite will be rotated around the orign. By setting an
%   offset the rotation point will change.
%
%   sprite('Scale',sc) Scale changes the size of the sprite
%
%   sprite('Orientation',theta) rotates the sprite. 
%
%   See also graphics/image for more properties which can be accesseed
%   through set and get or by using sprite.Image.propertyx

%   Urban Eriksson, 2019, (https://github.com/urban-eriksson) 

    properties
       Image
    end
    
    properties (SetObservable)
        Position, Offset, Scale, Orientation
    end
    
    properties (Access=private)
       tform, listener_enabled 
    end
    
    methods
        
        function obj = Sprite(varargin)
            
            obj.Position = [0 0];
            obj.Offset = [0 0];
            obj.Scale = 1;
            obj.Orientation = 0;
            [varargimage, ~, offset_input] = obj.arganalysis(varargin{:});
            obj.tform = hgtransform();
            obj.tform.Matrix = makehgtform('translate',[obj.Position 0], ...
                'scale', obj.Scale, ...
                'zrotate', obj.Orientation);
            ao = length(varargimage)+1;
            varargimage{ao} = 'Parent';
            varargimage{ao+1} = obj.tform;
            
            obj.Image = image(varargimage{:});   
            
            if offset_input
                obj.offset_event_handler();
            end
            
            addlistener(obj,'Position','PostSet',@obj.transform_event_handler);
            addlistener(obj,'Offset','PostSet',@obj.offset_event_handler);
            addlistener(obj,'Scale','PostSet',@obj.transform_event_handler);
            addlistener(obj,'Orientation','PostSet',@obj.transform_event_handler);
            
        end
        
        function delete(obj)
            delete(obj.tform)
        end
        
        function value = get(this, name)
            if strcmpi(name,'position')
                value = this.Position;
            elseif strcmpi(name,'scale')
                value = this.Scale;
            elseif strcmpi(name,'orientation')
                value = this.Orientation;
            elseif strcmpi(name,'offset')
                value = this.Offset;
            else
                value = get(this.Image, name);
            end
        end
        
        function set(this, varargin)
            [varargimage, tform_input, offset_input] = this.arganalysis(varargin{:});

            if  ~isempty(varargimage)
                set(this.Image,varargimage{:});
            end
            
            if offset_input
                this.offset_event_handler();
            end
            
            if tform_input
                this.transform_event_handler();
            end
            
        end
        
        % axis_oordinates are in the axis reference frame
        % ordered in a column vector
        % [x1 y1;
        %  x2 y2;
        %  ...
        %  xN yN]
        function c = get_color(this, axis_coordinates)
            N = size(axis_coordinates,1);
            sprite_coordinates = this.tform.Matrix\[axis_coordinates'; zeros(1,N); ones(1,N)];
            icolumns = round(sprite_coordinates(1,:)');
            irows = round(sprite_coordinates(2,:)');
            
            icolumns = icolumns - this.Offset(1);
            irows = irows - this.Offset(2);

            [rows,cols,~] = size(this.Image.CData);
            icolumns(icolumns < 1) = 1;
            icolumns(icolumns > cols) = cols;
            irows(irows < 1) = 1;
            irows(irows > rows) = rows;
            
            c = zeros(N,3);            
            ired = sub2ind(size(this.Image.CData),irows,icolumns,ones(N,1));
            c(:,1) = this.Image.CData(ired);
            igreen = sub2ind(size(this.Image.CData),irows,icolumns,2*ones(N,1));
            c(:,2) = this.Image.CData(igreen);
            iblue = sub2ind(size(this.Image.CData),irows,icolumns,3*ones(N,1));
            c(:,3) = this.Image.CData(iblue);            
        end
        
                % axis_oordinates are in the axis reference frame
        % ordered in a column vector
        % [x1 y1;
        %  x2 y2;
        %  ...
        %  xN yN]
        function a = get_alpha(this, axis_coordinates)
            N = size(axis_coordinates,1);
            sprite_coordinates = this.tform.Matrix\[axis_coordinates'; zeros(1,N); ones(1,N)];
            icolumns = round(sprite_coordinates(1,:)');
            irows = round(sprite_coordinates(2,:)');
            
            icolumns = icolumns - this.Offset(1);
            irows = irows - this.Offset(2);

            [rows,cols,~] = size(this.Image.CData);
            icolumns(icolumns < 1) = 1;
            icolumns(icolumns > cols) = cols;
            irows(irows < 1) = 1;
            irows(irows > rows) = rows;
            
            ix = sub2ind(size(this.Image.AlphaData),irows,icolumns);
            a = this.Image.AlphaData(ix);
        end

        
        % Coordinates given in the current axis reference frame
        % [x1 y1;
        %  x2 y2;
        %  ...
        %  xN yN]
        % Color values from 0 to 255
        function set_color(this, axis_coordinates, color)
            N = size(axis_coordinates,1);
            sprite_coordinates = this.tform.Matrix\[axis_coordinates'; zeros(1,N); ones(1,N)];
            icolumns = round(sprite_coordinates(1,:)');
            irows = round(sprite_coordinates(2,:)');
            
            icolumns = icolumns - this.Offset(1);
            irows = irows - this.Offset(2);
            
            [rows,cols,~] = size(this.Image.CData);
            icolumns(icolumns < 1) = 1;
            icolumns(icolumns > cols) = cols;
            irows(irows < 1) = 1;
            irows(irows > rows) = rows;
            
            ired = sub2ind(size(this.Image.CData),irows,icolumns,ones(N,1));
            this.Image.CData(ired) = color(1);
            igreen = sub2ind(size(this.Image.CData),irows,icolumns,2*ones(N,1));
            this.Image.CData(igreen) = color(2);
            iblue = sub2ind(size(this.Image.CData),irows,icolumns,3*ones(N,1));
            this.Image.CData(iblue) = color(3);
        end
        
        function axis_coordinates = get_axis_coordinates(this, sprite_coordinates)
            N = size(sprite_coordinates,1);
            hom_coords = this.tform.Matrix * [sprite_coordinates' ; zeros(1,N) ; ones(1,N)];
            axis_coordinates = hom_coords(1:2,:)';
        end
        
        % Occupancy = alpha > 0
        function is_occupied = get_occupancy(this, axis_coordinates)
            is_occupied = this.get_alpha(axis_coordinates) > 0;
        end
        
    end
    
    methods (Access=private)
        
        function [varargimage, tform_input, offset_input] = arganalysis(this, varargin)
            ai = 1;
            numArgs = length(varargin);
            ao = 1;
            varargimage = {};
            tform_input = false;
            offset_input = false;
            this.listener_enabled = false;
            while ai <= numArgs
                name = varargin{ai};
                ai = ai+1;
                if strcmpi(name,'position')
                    tform_input = true;
                    this.Position = varargin{ai};
                    ai = ai+1;
                elseif strcmpi(name,'offset')
                    offset_input = true;
                    this.Offset = varargin{ai};                    
                    ai = ai+1;
                elseif strcmpi(name,'scale')
                    tform_input = true;
                    this.Scale = varargin{ai};
                    ai = ai+1;
                elseif strcmpi(name,'orientation')
                    tform_input = true;
                    this.Orientation = varargin{ai};
                    ai = ai+1;
                else
                    varargimage(ao) = {name};
                    ao = ao+1;
                    varargimage(ao) = varargin(ai);
                    ai = ai+1;
                    ao = ao+1;
                end
            end
            this.listener_enabled = true;
            
        end
        
        function transform_event_handler(this, ~, ~)
            this.tform.Matrix = makehgtform('translate',[this.Position 0], ...
                         'scale', this.Scale, ...
                         'zrotate', this.Orientation);
        end
        
        function offset_event_handler(this, ~, ~)
            [rows, cols, ~] = size(this.Image.CData);
            set(this.Image,'XData',[1 cols] + this.Offset(1));
            set(this.Image,'YData',[1 rows] + this.Offset(2));
        end
        
        
    end
end

