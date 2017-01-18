%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Simulation of the paper:
%   A proximity-based Q-Learning Reward Function for Femtocell Networks
%
%% Initialization
clear;
clc;
format short
format compact

%% Parameters
Pmin = -20; %dBm
Pmax = 25; %dBm
Npower = 31;

dth = 25;
Kp = 100; % penalty constant for MUE capacity threshold
Gmue = 1.37; % bps/Hz
StepSize = 1.5; % dBm
K = 1000;
PBS = 50 ; %dBm
gamma_th = 10^(2/10);
%% Q-Learning variables
% Actions
actions = zeros(1,31);
for i=1:31
    actions(i) = -25 + (i-1) * 1.5; % dBm
end

% States
states = allcomb(0:1 , 0:3 , 0:3); % states = ( I , dMUE , dBS)

% Q-Table
Q = zeros(size(states,1) , size(actions , 2));

alpha = 0.5; gamma = 0.9; epsilon = 0.1 ; Iterations = 50000;
%% Generate the UEs
mue1 = UE(-200, 0);
BS = BaseStation(0 , 0 , 50);
FBS = cell(1,3);
for i=1:3
    FBS{i} = FemtoStation(180+(i-1)*35,150, BS, mue1, 10);
end
%% Generate Reward Matrix
Reward = zeros(size(states,1), size(actions,2));
for j=1:size(FBS,2)
    fbs = FBS{j};
    for i=1:size(actions,2)
        fbs = fbs.setPower(actions(i));
        mue1.SINR = SINR_MUE(FBS, BS, mue1, -120);
        mue1.C = log2(1+mue1.SINR);
        fbs = fbs.getDistanceStatus;
        if mue1.C >= gamma_th
            fbs.state(1) = 0;
        else
            fbs.state(1) = 1;
        end
        for kk = 1:32
            if states(kk,:) == fbs.state
                Reward(kk,i) = K - (mue1.SINR - 2)^2;
            end
        end
    end
    FBS{j} = fbs;
end
%% Main Loop
for episode = 1:Iterations
    % random initial state
    y=randperm(size(R,1));
    state=y(1); % current state
    
%     while state~=goalState            % loop until find goal state
        % select any action from this state
        x=find(R(state,:)>=0);         % find possible action of this state
        if size(x,1)>0,
            x1=RandomPermutation(x);   % randomize the possible action
            x1=x1(1);                  % select an action (only the first element of random sequence)
        end

        qMax=max(q,[],2);
        q(state,x1)= R(state,x1)+gamma*qMax(x1);     % get max of all actions from the next state for Q of current state
        state=x1;
%     end 
end




