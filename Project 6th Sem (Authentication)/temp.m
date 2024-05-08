%sc = satelliteScenario();
%viewer = satelliteScenarioViewer(sc);

%trajectory = geoTrajectory([28.5567,77.1006,10600;13.1989, ...
%    77.7068,30600;25.2566,55.3641,5600;28.5567,77.1006,10600], ...
%    [0,3600,3*3600,3*4000],AutoPitch=true,AutoBank=true);

%pltf = platform(sc,trajectory);

%pltf.Visual3DModel = 'NarrowBodyAirliner.glb';

%hide(pltf.Path);
%show(pltf.GroundTrack);

%play(sc);

sc = satelliteScenario();
viewer = satelliteScenarioViewer(sc);
trajectory = geoTrajectory([38.7223,-9.1393,0;38.7223,-9.1393,0;55.7558,37.6176,0], ...
    [0,4*60,9*60],AutoPitch=true,AutoBank=true);
pltf = platform(sc,trajectory);
pltf.MarkerColor = [0 0 1];
pltf.Visual3DModel = 'NarrowBodyAirliner.glb';
hide(pltf.Path);
show(pltf.GroundTrack);
play(sc);

