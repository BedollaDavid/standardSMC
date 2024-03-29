clc, clear, close all

path = [ genpath('plant'), genpath('results'), genpath('trajectories')];
addpath(path)

grados=2
Ts=1e-3;
Tg=1e-3;

ShowRobot='on'; % on off
SimulationMode='normal'; %accel normal
solver='ode4'; % 'ode3', 'ode1'
saveResult=false;

gain=1.0; %simscape physical parameters
Pert=0.0; %External perturbation amplitude
Offset=0.0; % offset from trajectory initial position (degrees)

    if grados==2
        RRPLANAR_DataFile
        %Max torque
        limU=[60 40]';
        limD=-[60 40]';
        Tsim=4;
        pos=[0 0 pi/2 pi/2 0;0 0 pi/4 pi/4 0];
        [Qcoef,time1,dq,dqd,dqdd]=pol5(pos,pos*0,pos*0,0,Tsim,Ts);
        %[Qcoef,time1,dq,dqd,dqdd]=pol3(pos,pos*0,0,Tsim,Ts);
        q0=[0 0]';
        qd0=[0 0]';
    end

Gname=['G' num2str(grados) 'Rn'];
IMname=['InvMass' num2str(grados) 'Rn' ];
Mname=['Mass' num2str(grados) 'Rn' ];
Mname2=['Mass' num2str(grados) 'RnV2' ];
Vname=['V' num2str(grados) 'Rn' ];

q01=q0+(Offset*pi/180);
for i=1:size(smiData.RevoluteJoint,2)
    smiData.RevoluteJoint(i).Rz.Pos=q01(i)*180/pi;
    smiData.RevoluteJoint(i).Rz.Vel=qd0(i)*180/pi;
end

% Sliding Mode Control Gains
K=2; lambda=20;

r=sim('Robot2','SrcWorkspace','current','SimMechanicsOpenEditorOnUpdate',ShowRobot,'SimulationMode',SimulationMode,'solver',solver);

FullSim=size(r.q,1)*Ts>=Tsim;
%%%% Writting results
if saveResult & FullSim
    name=rand_name()
    r.Ts=Ts;
    save(['results/SIM' num2str(grados) '_'  name '.mat'],'r');
end
plotData