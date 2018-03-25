model obj_drawing   
//import "googlebackground.gaml"

global {
	string s <- "1|2|3";
	float step<-1#h;
	date start_date <- date( [2018,3,21,0,0,0]);
	list<int> ln <- [1,1,2,2,2,3,55] update:ln;
	list<string> lss <- ['1','1','2','2','a'];
	map<string, int> msi;
	int i <- 1 among:ln parameter:true;
	date starting_date <- date("2018-03-21 14:10:01");
	
	init { 
		write "today is " + starting_date.day_of_week;
		//write 
		map<int,list<float>> mmm;
		int ik <- 2;
		list<int> inl ;
		add 1 to: inl;
		add 2 to: inl;
		add 3 to:inl;
		write "----" + inl;
		
		map<int, int> intmap <- [33::10,44::20];
		write "--- >>" + (intmap.pairs with_max_of each.key).value;
		
		map<int, list<int>> a <- [1::[1,2,3,14], 2::[1,2,3,16]];
		write a.values;
		write a;
		write "=======";
		write a;
		write a.keys;
		//write a.values max_of(each);
		write (a.pairs with_max_of(each.value[3])).key;
		
		write a.values[1] with_max_of(each);
		
		write (a.pairs with_max_of(last(each.value))).key;
		write a.pairs;
		
		
		
		
		if current_date.hour = 14{
			write "midnight" ;
		} else {
			write current_date plus_minutes 10;
		}
		
		//write rnd(date("2018-02-22 14:10:01"),date("2018-02-22 14:10:01"));
		mmm[ik] <-  [3,4];
		write "this is mmm :" + mmm;
		msi["bike"] <- 10;
		add 10 to:ln at:length(ln);
		msi["auto"] <- 50;
		write msi;
		list<string> ls<- split_with(s,"|");
		bool a<- ls contains '1' ;
		write a;
		create object number: 1;
		write list(start_date)[3];
		write start_date.hour;
		map<int, list<int>> m<- group_by(ln,(each));
		write "m=" + m;
		//write max();
		list<int> counts<- m.values accumulate length(each);
		write m.keys at (counts index_of max(counts));
		//write (max(counts));
		//write max(m.values);
		write ln split_in length(distinct(ln)) collect length(each);
		//write lss split_in length(distinct(lss)) collect length(each);
		write [1::2, 3::4, 5::6] index_of 6; 
		//matrix mm<- as_matrix(create_map(ln,ln));
	}  
	
	reflex dosomerhing when: after (start_date add_days 1#day){
		write "hello";
	}
} 

species object skills: [moving]{
	point target <- any_location_in(world);
	reflex move  {
		do goto target: target ;
		if (target = location) {
			target <- any_location_in(world);
		}
	}
	aspect obj {
		//draw obj_file("../includes/pt_related/tram.obj", 90::{-1,0,0}) at: location + {0,0,2.0} size: 30.0 color: rgb(#blue,0.5) rotate: heading;
		
	}
}	

experiment Display  type: gui {
	parameter "nonsense" var:i ;
	output {
		display ComplexObject type: opengl{
			species object aspect:obj;		
			
			graphics "g" {
				draw obj_file("../includes/landmarks/station/edited_station.obj", 90::{-1,0,0}) at: {50,50,0}  size: 20.0 color: rgb(#blue,0.5) ;
			}		
		}
	}
}