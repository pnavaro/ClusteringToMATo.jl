function Ha_out = display_diagram(varargin)

% DISPLAY_DIAGRAM  Displays persistence diagrams
%
%    DISPLAY_DIAGRAM(X) displays the persistence diagram stored in the n-by-2 
%    matrix X, where each row stores the coordinates of a point of the diagram.
%
%    DISPLAY_DIAGRAM(X,tau) displays the diagram stored in X as above, 
%    plus it displays the shifted diagonal line corresponding to the 
%    prominence threshold value tau.
%
%    This script has been adapted by S. Oudot from the PX_HOMOLOGYPLOT
%    script by P. Perry and V. de Silva (Plex 2005).
%


%----------------------------------------------------------------
% trap errors and initialise

[pairs, tau, err] = local_initialise(varargin{:});
error(err);

%----------------------------------------------------------------
% set up one subplot for each betti number
   figure(gcf);
   clf reset
   Ha = subplot(1, 1, 1);

%----------------------------------------------------------------
% determine range of data

[Fmin,Fmax,Imin,Imax] = local_minmax(pairs);
% [Fmin,Fmax] = range spanned by finite entries
% [Imin,Imax] = range spanned by all entries (may include +/- inf)

%----------------------------------------------------------------
% use MATLAB autoarrange algorithm to determine x-axis tickmarks

if isnan(Fmin)
  % exceptional case: no finite filtration values
  xmin = -1;
  xmax = 1;
  xtick = [-1 1];
end

  axes(Ha);
  Ho = plot([Fmin, Fmax], [0 0]);
  xtick = get(Ha, 'xtick');
  delete(Ho);
  cla(Ha,'reset')
  
  xmin = xtick(1);
  xmax = xtick(end);
  
  % extend range to accommodate +inf, -inf
  xstep = (xtick(2) - xtick(1)) * (0.618);
  if isinf(Imin)
    xmin = xmin - xstep;
  end
  if isinf(Imax)
    xmax = xmax + xstep;
  end


%keyboard

%----------------------------------------------------------------
% plot loop
    
    kpairs = pairs;
    inflist = any(isinf(kpairs), 2);
    
    
    kpairs(kpairs(:) == -inf) = xmin + eps;
    kpairs(kpairs(:) == inf) = xmax - eps;
    
    
    
    axes(Ha)
    cla(Ha,'reset');
    axis equal

    hold on
    
    % delimitate finite area
    Ho = line([0 xmax], [0 0]);
    set(Ho, 'color', get(gcf,'color'), 'linewidth', 0.5, 'linestyle', '--');
    Ho = line([0 0], [-xmax 0]);
    set(Ho, 'color', get(gcf,'color'), 'linewidth', 0.5, 'linestyle', '--');

    % grey out region above diagonal
    Ho = patch([xmin xmin xmax],[xmin xmax xmax],'k');
    set(Ho, 'facecolor', get(gcf,'color'));

    % draw diagonal line corresponding to threshold
    if (~isinf([tau]))
        Ho = line([tau xmax],[0 xmax-tau]);
        set(Ho, 'color', get(gcf,'color'), 'linewidth', 2);
        Ho = line([tau tau],[xmin 0]);
        set(Ho, 'color', get(gcf,'color'), 'linewidth', 2);
    end
        
    % plot diagram below diagonal
    Ho = plot(kpairs(~inflist,1), kpairs(~inflist,2), '.b');
    set(Ho, 'markersize', 20);
    Ho = plot(kpairs(inflist,1), kpairs(inflist,2), '.b');
    set(Ho, 'markersize', 20);
        
    
    
    
    hold off
    
    set(Ha, 'xaxislocation', 'top');
    set(Ha, 'xtick', xtick);
    set(Ha, 'xtickmode', 'manual');
    set(Ha, 'xlim', [xmin xmax]);
    
    set(Ha, 'ytick', xtick);
    set(Ha, 'ytickmode', 'manual');
    set(Ha, 'ylim', [xmin xmax]);

    xlabel(sprintf('Persistence Diagram'));
    
    % end: 'scatter'
    %----------------------------------------    
%  end  



%----------------------------------------------------------------
% return
if (nargout == 1)
  Ha_out = Ha;
end
return

%----------------------------------------------------------------
% local functions
%----------------------------------------------------------------

%----------------------------------------------------------------
% parse the input to extract the relevant parameters
function [pairs, tau, err] = local_initialise(varargin)

% dummy values for output arguments
% (needed in case of early 'return' on error)
tau = Inf;
pairs = [];
err = [];

err = nargchk(1, 2, nargin);
if err
  return
end

if (nargin == 2)
    tau = varargin{2};
end

% extract and process interval pairs data
pairs = varargin{1};
[pairs, err] = local_checkpairs(pairs);
if err
  return
end

% determine range of dimensions
  k1 = 0;
  k2 = length(pairs) - 1;
  

err = local_checkinteger(k1, k2);
if err
  return
end
  
if (max(k1,k2) >= length(pairs))
  err = 'Specified dimensions out of range.';
  return
end

if (k1 <= k2)
  klist = (k1: k2);
else
  klist = (k1: -1: k2);
end

return

%----------------------------------------------------------------
function [pairs, err] = local_checkpairs(pairs)
err = [];
  if ~isnumeric(pairs) || (size(pairs, 2) ~= 2)
    err = 'Interval data is incorrectly specified.';
    return
  else
    % retain negative pairs only
      pairs = pairs((pairs(:,1) >= pairs(:,2)), :);
  end

return

%----------------------------------------------------------------
function err = local_checkinteger(varargin)
% all inputs are required to be integers
err = [];
for a = (1: nargin)
  k = varargin{a};
  if ~isnumeric(k) || (length(k) > 1) ...
        || ~isequal(k,floor(k)) || (k < 0)
    err = 'Dimension values must be nonnegative integers.';
    return
  end
end
  
%----------------------------------------------------------------
function [Fmin,Fmax,Imin,Imax] = local_minmax(pairs)
% Fmin, Fmax denote the min and max of the finite entries of pairs{:}
% Imin, Imax denote the min and max of all the entries of pairs{:}

% all entries, finite and infinite
pairs_ = unique(pairs);
if ~isempty(pairs_)
  Imax = max(pairs_);
  Imin = min(pairs_);
else
  Imax = NaN;
  Imin = NaN;
end

% finite entries only
pairs_ = pairs(isfinite(pairs(:)));
if ~isempty(pairs_)
  Fmax = max(pairs_);
  Fmin = min(pairs_);
else
  Fmax = NaN;
  Fmin = NaN;
end


%----------------------------------------------------------------

%----------------------------------------------------------------
