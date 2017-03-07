function c = dynesfulton(inputfile)
  % Import data from an input file
  data    = load(inputfile);
  field   = data(:,1);
  current = abs(data(:,2));

  % Estimate the local curvature
  c = curvature(current, field);

  % Identify spikes in the curvature
  u = trim(spikes(c));

  % Create a sign array that flips after each spike
  s = (-1) .^ cumsum(u);

  % Use this to restore the sign of the measured current
  current = s .* current;

  % Interpolate the input data to a higher precision
  field_i   = linspace(min(field), max(field), 4096);
  current_i = pchip(field, current, field_i);

  % Plot the reconstruction and interpolation
  current_p = current;
  current_m = current;
  current_p(current < 0) = NaN;
  current_m(current > 0) = NaN;
  plot(field_i, current_i, 'k-', field, current_p, 'b.', field, current_m, 'r.');
  xlabel('Applied field H');
  ylabel('Charge current I');

  % Perform a Fourier transform
  % TODO: Make this part work
  fourier = ifft(field)
end

function v = trim(u)
  % Takes a boolean array, and replaces consecutive true-valued regions in the array
  % with a single true element in the center of the region. For instance:
  %  trim([0,1,1,1,0,0,0,1,1,1,1,1,0,0]) = [0,0,1,0,0,0,0,0,0,1,0,0,0,0]

  % Differentiate the boolean array — the result should be +1 at the start of a
  % true-valued region, -1 at the end of such a region, and 0 otherwise
  d = diff(u);

  % Identify the start and stop of true-valued regions
  p = find(d > 0);
  q = find(d < 0);

  % Finally, construct the trimmed boolean array
  v = zeros(size(u));
  for n=1:min(size(p),size(q))
    v(ceil(1+p(n)/2+q(n)/2)) = 1;
  end
end

function u = spikes(y)
  % Uses an outlier-detection algorithm to identify abberant maxima in a dataset.

  % Find the median and median-absolute-deviation of the input array
  N = length(y);
  m = median(y);
  s = mad(y,1);

  % Identify regions that exceed a statistical threshold value
  u = y > m + 3*s;
end

function c = curvature(y, x)
  % Calculates the local curvature of some function y(x), using a finite-difference
  % approximation for the numerical derivatives dy/dx and d²y/dx² of the arrays.

  % Calculate the first and second derivatives
  d1 = differentiate1(y, x);
  d2 = differentiate2(y, x);

  % Calculate the signed local curvature 
  c = d2 ./ (1+d1.^2).^(3/2);
end

function d = differentiate1(y, x)
  % Calculates the first-derivative dy/dx, using a central-difference approximation in 
  % the interior domain, and a forward/backward-difference approximation at the edges.

  % Initialize variables
  N = min(length(x),length(y));
  d = zeros(N,1);

  % Calculate the finite-difference first-derivative
  d(  1  ) = (y( 2 )-y(  1  )) ./ (x( 2 )-x(  1  ));
  d(2:N-1) = (y(3:N)-y(1:N-2)) ./ (x(3:N)-x(1:N-2));
  d(  N  ) = (y( N )-y( N-1 )) ./ (x( N )-x( N-1 ));
end

function d = differentiate2(y, x)
  % Calculates the second-derivative d²y/dx², using a central-difference approximation
  % in the interior domain of the function y(x), and skipping calculation at the edges.

  % Initialize variables
  N = min(length(x),length(y));
  d = zeros(N,1);

  % Calculate the finite-difference second-derivative
  d(2:N-1) = 4 * (y(3:N) - 2*y(2:N-1) + y(1:N-2)) ./ (x(3:N) - x(1:N-2)).^2;
end