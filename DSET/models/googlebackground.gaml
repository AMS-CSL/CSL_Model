/**
* Name: googlebackground
* Author: bhami001
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model googlebackground

/* Insert your model definition here */

/**
* Name: GoogleMapsImageImport
* Author: Alexis Drogoul
* Description: Demonstrates how to load a (possibly dynamic) image from Google Maps and how to refresh it
* Tags: data_loading, displays, user_input, on_change
*/


 
global
{
	file shape_file_buurt <- file('../includes/Centrum_zones_numerical1.shp');
 	//file shape_file_trams <- file("../includes/pt_related/TRAMMETRO_LIJNEN_projected.shp");
 	geometry shape <- envelope(shape_file_buurt);
 	
	image_file google_request;
	map
	answers <- user_input("Address can be a complete address (e.g. 'Paris,France') or a pair lat,lon (e.g; '48.8566140,2.3522219')", ["Address"::"Amsterdam"]);
	string center_text <- answers["Address"];
	bool visib_flag <- false;
	int zoom_text <- 13;
	action load_map
	{
		string visibility <- "visibility:" + (visib_flag ? "on" : "off");
		string zoom <- "zoom=" + zoom_text;
		string center <- "center=" + center_text;
		google_request <-
		image_file("http://maps.google.com/maps/api/staticmap?" + center + "&" + zoom + "&size=850x850&maptype=roadmap&style=feature:all%7Celement:labels%7C" + visibility)
	}
 
	init
	{
		do load_map;
		create zones from:shape_file_buurt;
		//create trams from:shape_file_trams;
	}

}

species trams{
	aspect a{
		draw shape color:#black;
	}
}
species zones{
	aspect a{
		draw shape color:rgb(#gray,0.2);
	}
}
experiment Display
{
	
	parameter "Zoom" var: zoom_text on_change: {
		ask simulation  {do load_map;}
		do update_outputs(true);
	};
	
	parameter "Labels" var: visib_flag on_change: {
			ask simulation  {do load_map;}
			do update_outputs(true);
	};
	output
	{
		display "Google Map" type: opengl
		{
			image google_request;
			species zones aspect:a;
			species trams aspect:a;
		}

	}

}

