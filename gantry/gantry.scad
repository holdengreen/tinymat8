$fa = 0.00001;
$fs = 0.2;

CORNER_RAD = 6;
OUTER = 104;
HEIGHT = 8.6-2;

module block()
{
	s = OUTER-(CORNER_RAD*2);
	translate([s/2, s/2, 0]) minkowski()
	{
		translate([-s/2, -s/2, 0]) cylinder(r=CORNER_RAD, h=HEIGHT/2, center=true);
	    cube([s,s, HEIGHT/2], center=true);
	}
}

EXTRA = 0.1;
module cutout()
{
	D = 7.5;
	STEP = 10+2;
	START = -47+(STEP/2)-1;
	for(i= [0:7])
	{
		x = START+(STEP*i);
		for(i2= [0:7])
		{
			y = START+(STEP*i2);
			translate([x, y, 0]) cube([D, D, HEIGHT*4], center=true);
		}
		echo(i);

	}
	O = (OUTER/2)-2.3;
	translate([O, 0, 0]) cylinder(r=1.5, h=HEIGHT*10, center=true);
	translate([-O, 0, 0]) cylinder(r=1.5, h=HEIGHT*10, center=true);
	translate([0, O, 0]) cylinder(r=1.5, h=HEIGHT*10, center=true);
	translate([0, -O, 0]) cylinder(r=1.5, h=HEIGHT*10, center=true);

}

module final()
{
	translate([0, 0, -HEIGHT/2]) difference()
	{
		block();
		cutout();
	}
}

final();
