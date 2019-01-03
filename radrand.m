function [xrand, yrand] = radrand(varargin)
% radially uniform distribution
% Arguments Rmax, Rmin
rmax=1;rmin=0;sz=[];

ai = 1;
numArgs = length(varargin);
while ai <= numArgs
    arg = varargin{ai};
    ai = ai+1;
    if ischar(arg)
        if strcmpi(arg,'Rmax')
            rmax = varargin{ai};
            ai = ai+1;
        elseif strcmpi(arg,'Rmin')
            rmin = varargin{ai};
            ai = ai+1;
        end
    elseif isnumeric(arg)
        sz = [sz arg];
    end
end

if isempty(sz)
    sz = 1;
end


% Uniform in theta
thetarand = 2 * pi * rand(sz);

if rmin == 0
    rrand = sqrt(rand(sz)) * rmax;
else
    k = rmin / rmax;
    rrand = sqrt(k^2 + (1-k^2)*rand(sz)) * rmax;
end
    
xrand = rrand.*cos(thetarand);
yrand = rrand.*sin(thetarand);