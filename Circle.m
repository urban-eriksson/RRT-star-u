classdef Circle < handle
%CIRCLE Create 2D circle
%   CIRCLE('Position',pos,'Radius',r,...) creates a circle in 2-D coordinates
%   centered at pos with radius r. For additional properties see RECTANGLE
%
%   See also graphics/rectangle.

%   Urban Eriksson, 2019, (https://github.com/urban-eriksson) 

    properties
        Rectangle
    end
    
    properties (SetObservable)
        Radius, Position
    end
    
    properties (Access=private)
        listener_enabled
    end
    
    methods
        function obj = Circle(varargin)
            obj.Position = [0 0];
            obj.Radius = 1;
            varargrect = obj.arganalysis(varargin{:});
            ao = length(varargrect)+1;
            varargrect{ao} = 'Position';
            varargrect{ao+1} = [obj.Position-obj.Radius 2*obj.Radius 2*obj.Radius];
            varargrect{ao+2} = 'Curvature';
            varargrect{ao+3} = [1 1];

            obj.Rectangle = rectangle(varargrect{:});
            
            addlistener(obj,'Position','PostSet',@obj.set_position_radius_event_handler);
            addlistener(obj,'Radius','PostSet',@obj.set_position_radius_event_handler);
            obj.listener_enabled = true;
        end
        
        function delete(obj)
            delete(obj.Rectangle)
        end
        
        function value = get(this, name)
            if strcmpi(name,'position')
                value = this.Position;
            elseif strcmpi(name,'radius')
                value = this.Radius;
            else
                value = get(this.Rectangle, name);
            end
        end
        
        function set(this, varargin)
            [varargrect, got_pos_rad] = this.arganalysis(varargin{:});
            if got_pos_rad
                ao = length(varargrect)+1;
                varargrect{ao} = 'Position';
                varargrect{ao+1} = [this.Position-this.Radius 2*this.Radius 2*this.Radius];
            end
            set(this.Rectangle,varargrect{:});
        end
    end
    
    methods (Access=private)
        
        function [varargrect, got_pos_rad] = arganalysis(this, varargin)
            ai = 1;
            numArgs = length(varargin);
            ao = 1;
            varargrect = {};
            got_pos_rad = false;
            this.listener_enabled = false;
            while ai <= numArgs
                name = varargin{ai};
                ai = ai+1;
                if strcmpi(name,'radius')
                    got_pos_rad = true;
                    this.Radius = varargin{ai};
                    ai = ai+1;
                elseif strcmpi(name,'position')
                    got_pos_rad = true;
                    this.Position = varargin{ai};
                    ai = ai+1;
                elseif strcmpi(name,'curvature')
                    ai = ai+1;
                else
                    varargrect(ao) = {name};
                    ao = ao+1;
                    varargrect(ao) = varargin(ai);
                    ai = ai+1;
                    ao = ao+1;
                end
            end
            this.listener_enabled = true;
        end
        
        function set_position_radius_event_handler(this, ~, ~)
            if this.listener_enabled
                set(this.Rectangle,'Position',[this.Position-this.Radius 2*this.Radius 2*this.Radius]);
            end
        end
    end
end
    
    