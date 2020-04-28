function rst_view(rs, rv, sv, PKTRACE, h_sub)
% RST_VIEW view the rate-scale plot along the time axis
%	rst_view(rs, rv, sv, PKTRACE, h_sub);
%	rs = [rs1 rs2 rs3 .. rsN]: rate-scale matrix 
%	rv      : rate vector in Hz, e.g., 2.^(1:.5:5).
%       sv      : sacel vector in cyc/oct, e.g., 2.^(-2:.5:3).
%	PKTRACE : (optional) peak-trace plot (default = 0)
%		  0: rate-scale response plot
%		  1: rate-scale peak-trace plot
%		  2: enhanced rate-scale plot using Laplacian weighting
%	h_sub	: (optional) handles of two subplots
%
%	RST_VIEW views the output has to be generated by COR2RST.
%	This function will plot the negative rate plot in the left panel,
%	and positive one on the right panel. If PKTRACE > 0, a peak-trace
%	plot will be displayed. The handle of subplots can preassigned 
%	through [h_sub].
%	See also: COR2RST, AUD2COR, AUD2RST

% Auther: Powen Ru (powen@isr.umd.edu), NSL, UMD
% v1.00: 01-Jun-97
% v1.01: 14-Jun-97, colormap changed from <jet> to <a1map>
% v1.02: 25-Jun-97, included peak trace option, colormap auto-detect,
%		    fixed RSLIM, subplot assignment 
% v1.03: 26-Jun-97, included Laplacian weighting
% v1.04: 30-Jul-97, make it executable in Matlab4

global TICKLABEL VER;

% dimensions
[K2, N] = size(rs);
if length(sv) ~= K2, error('Size mismatch !'); end;
K1	= length(rv);
N	= N / K1 /2;
sgnstr	= '-+';

% graphics parameter
NTIMES	= 2;	dK = 2^(-NTIMES);
max_rs	= max(rs(:));
RSLIM	= max_rs/1.2;
disp(sprintf('Max: %3.1e; Mean: %3.1e', max_rs, mean(rs(:))));

% xtick labels
xtic = []; xtlabel = []; Kx = 5;
for k = 1:K1,
	R1 = log2(rv(k));
	if abs(R1-round(R1)) < .001,
		xtic = [xtic k];
		xtlabel = [xtlabel; '-', sprintf('%4.1f', rv(k))];
	end;
end;

% ytick labels
ytic = []; ytlabel = [];
for k = 1:K2,
        R1 = log2(sv(k));
        if abs(R1-round(R1)) < .001,
                ytic = [ytic k];
                ytlabel = [ytlabel; sprintf('%4.2f', sv(k))];
        end;
end;

% options
if nargin < 4, PKTRACE = 0; else, rs1 = 0; rs2 = 0; end;
if nargin < 5, h_sub = [subplot(121) subplot(122)]; end;

% detect colormap
A1MAP = isa1map;
 
for n = 1:N,
	for sgdx = 1:2,
		% select subplot 
		subplot(h_sub(sgdx));

		% constructing rate-scale matrix
		rs0 = rs(:, (1:K1)+(n-1)*2*K1+(sgdx-1)*K1);

		% select ploting object
		if PKTRACE,
			if VER < 5,
				rs0 = interp2(1:K1, 1:K2, rs0, ...
                                        1:.5:K1, 1:.5:K2, 'cubic');
			else,
				rs0 = interp2(rs0, 1, 'cubic');
			end;
			if PKTRACE == 2,
				rsw = del2(rs0);
				rsw = rsw / max(rsw(:)); 
			else,
				rsw = peakpick(rs0, 2);
			end;
			%rs0 = rsw .* rs0;
			rs0 = rsw * max(rs0(:))/2;

			if sgdx == 1,
				rs0 = rs0*.6 + rs1*.4; rs1 = rs0;
			else
				rs0 = rs0*.6 + rs2*.4; rs2 = rs0;
			end;
		else,
			if VER < 5,
				rs0 = interp2(1:K1, 1:K2, rs0, ...
					1:dK:K1, 1:dK:K2, 'cubic');
			else,
				rs0 = interp2(rs0, NTIMES, 'cubic');
			end;

		end;

		% select colormap 
		if A1MAP,
			rs0 = real_col(rs0, RSLIM);
			image(1:K1, 1:K2, rs0);
		else,
			imagesc(1:K1, 1:K2, rs0, [0 RSLIM]);
		end;
		axis xy;

		if sgdx == 1, set(gca, 'Xdir', 'rev'); end;
		text('position', [(K1+1)/2 K2*.9], 'str', ...
			[num2str(n) sgnstr(sgdx)], ...
			'fontsi', 16, 'co', 'k', 'ho', 'ce');
		set(gca, 'xtick', xtic, ...
			['x' TICKLABEL], xtlabel(:, sgdx:Kx), ...
			'ytick', ytic, ['y' TICKLABEL], ytlabel, ...
			'fontsi', 6);
	end;
	drawnow;
end;
