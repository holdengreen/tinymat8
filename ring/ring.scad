$fa = 0.00001;
$fs = 0.1;
toler = 0.2;
extra = 0.1;

OUTER = 104;
INNER = 94;
RAD = 5.211;
//H = 20;
H = 3;




module outer()
{
MIN = OUTER-(RAD*2);

translate([(-MIN/2)+RAD, (-MIN/2)+RAD, 0])
{
	minkowski()
	{
		cube([MIN, MIN, H]);
		cylinder(r=RAD, h=H);
	}
}
}


module inner(toler=0.0, H=0.0)
{
	MIN = INNER+(toler*2)-(RAD*2);
	translate([(-MIN/2)+RAD, (-MIN/2)+RAD, -extra/2])
	{
		minkowski()
		{
			cube([MIN, MIN, H+extra]);
			cylinder(r=RAD, h=H+extra);
		}
	}
}

module panel()
{
	H = 5;
	HANG = 1;
	INN = 3;
	SPACE = 2;
	ELEM = 10;
	START = (-47)+5;
		for(x = [0:1])
		{
			translate([START+(x*(ELEM+SPACE)), START, 0])
			cube([10, 10, 30], center=true);
		}
	difference()
	{
		color([0.5, 0, 0]) inner(toler=0, H=5);
		/*
		for(y=[1:6])
		{
			for(x = [0:8])
			{
				translate([START+(x*(ELEM+SPACE))+0.20, START+y*(ELEM+SPACE), 0])
				cube([10, 10, 20]);
			}
		}
		for(x = [1:6])
		{
			translate([START+(x*(ELEM+SPACE)), -START, 0])
			cube([10, 10, 20]);
		}
		*/
	}
}
//panel();

translate ([-5, -5, 0]) difference()
{
outer();
color([1, 1, 1]) inner(toler, H);
}
