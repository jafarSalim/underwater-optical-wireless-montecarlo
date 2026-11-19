function c = palette()
%PALETTE  "Abyss" colours: blue-green light sinking into dark water.
c.bg     = [0.01 0.05 0.09];
c.panel  = [0.02 0.09 0.15];
c.fg     = [0.88 0.97 1.00];
c.grid   = [0.10 0.24 0.33];
c.muted  = [0.50 0.68 0.76];
c.water  = {[0.35 0.85 1.00], [0.10 0.95 0.75], [0.95 0.85 0.25], [1.00 0.45 0.35]};  % pure, clear, coastal, harbor
c.laser  = [0.25 1.00 0.45];
c.white  = [1 1 1];
c.pink   = [1.00 0.40 0.80];
c.lw     = 2.4;
k = [0 0.01 0.05 0.09; 0.3 0.00 0.25 0.40; 0.6 0.00 0.65 0.70; 0.85 0.45 0.95 0.75; 1 0.95 1.00 0.90];
x = linspace(0, 1, 256)';
c.map = [interp1(k(:,1),k(:,2),x) interp1(k(:,1),k(:,3),x) interp1(k(:,1),k(:,4),x)];
end
