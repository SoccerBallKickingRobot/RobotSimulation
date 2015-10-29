function Robot = Simulation1(Robot)
%% ================Inverse Kinematic Tracing Trajectories==================

%[RobotFigure, states] = SetupKeyboardControl;

% Sets up the kinematics
controlPoint = 3;
KC = Robot.KinematicChains.RL;
KC.optimization.weightings(controlPoint) = 1;
pointsd = zeros(4, size(KC.points.kP,2));

% Trajectory parameters
traj.traj = 1;      % {1, 2}
traj = TrajectoriesRobotLeg(0, traj);

% History vectors for the desired trajectories
histD = zeros(traj.runs,3);

% History vectors for the actual trajectories
histT = zeros(traj.runs,3);
states.run = 1;
while (states.run)
    % Runs the loop a given number of times
    for i = 1:traj.velocity:traj.runs
        
        % Get current states
        %states = guidata(RobotFigure);
        %if (~states.run), break; end;
        
        % Create the trajectory
        traj = TrajectoriesRobotLeg(i, traj);
        
        % Assigns the desired trajectory history
        histD(i,:) = traj.point';
        
        % Inverse kinematics (Noise can be added or removed)
        pointsd(:,controlPoint) = [traj.point; 1] ...
            + traj.noise*[NoiseCalc;NoiseCalc;NoiseCalc;1];
        X = InverseKinematicOptimization(KC,pointsd);
           
        % Rotates and plots the Robot object
        KC = RotateKinematicChain(KC,X);
        Robot.KinematicChains.RL = KC;
        RobotPlot(Robot);   
        
        % Plots the ghost trajectories
        histT(i,:) = KC.points.kPG(1:3,controlPoint)'; MS = 10;
        plot3(histD(:,1),histD(:,2),histD(:,3),'Marker','.','color','green',...
            'MarkerSize',MS,'LineStyle','none');
        plot3(histT(:,1),histT(:,2),histT(:,3),'Marker','.','color','red',...
            'MarkerSize',MS,'LineStyle','none');
        drawnow;
    end
end