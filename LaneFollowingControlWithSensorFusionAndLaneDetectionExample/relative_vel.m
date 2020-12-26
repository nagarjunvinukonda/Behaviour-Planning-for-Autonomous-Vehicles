% This is a cost library for realtive velocities
% C is variale for relative velocities

x=[-10,-8,-0.5,0,0.5,8, 10]; 
y=[0,0.02,0.4,1,0.4,0.02,0]; 

figure
% plot(x,y)
title('Relative velocity error');
xlabel('Relative velocities(m/s)');
ylabel('Cost');

C = plot(x,y);


