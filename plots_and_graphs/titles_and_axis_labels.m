x = (1:20)';

m1 = 2; 
b1 = 3;
y1 = m1*x + b1 + 5*rand(size(x));

m2 = 6; 
b2 = -20;
y2 = m2*x + b2 + 5*rand(size(x));

figure;
label1 = ['m=', num2str(m1, '%.1f'), ', b=', num2str(b1, '%.1f')]; % One example of how to build a label string
label2 = sprintf('m=%.1f, b=%.1f', m2, b2);                        % A simpler way of building a label string
plot(x, y1, 'ro', 'DisplayName', label1);
hold on;
plot(x, y2, 'b^', 'DisplayName', label2);
title({'This is', 'an example of', 'a multi-line title'})
xlabel('Single subscript: t_i, Long subscript: t_{initial} ')
ylabel({'Axis label with Greek characters \pi\mu\sigma'});
legend('Location', 'Best');
improvePlot;