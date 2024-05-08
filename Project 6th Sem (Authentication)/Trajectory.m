startTime = datetime(2020,5,1,11,36,0);
stopTime = startTime + days(1);
sampleTime = 60;
sc = satelliteScenario(startTime,stopTime,sampleTime);
lat = 10;
lon = -30;

geoTrajectory()
trajectory = geoTrajectory([35.6895,139.6917,0;40.7128,-74.006,0],[0,10],AutoPitch=true,AutoBank=true);
pltf = platform(sc,trajectory);


semiMajorAxis = 10000000;
eccentricity = 0;
inclination = 10; 
rightAscensionOfAscendingNode = 0; 
argumentOfPeriapsis = 0; 
trueAnomaly = 0; 
sat = satellite(sc,semiMajorAxis,eccentricity,inclination, ...
        rightAscensionOfAscendingNode,argumentOfPeriapsis,trueAnomaly);

ac = access(sat,pltf);
intvls = accessIntervals(ac)

play(sc)