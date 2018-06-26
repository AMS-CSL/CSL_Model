/**
* Name: behavior
* Author: bhami001
* Description:  Depending on relative satisfaction and relative uncertainty, inhabitant will have a behavior.
* Tags: Tag1, Tag2, TagN
*/

model behavior

global {
	/** Insert the global definitions, variables and actions here */
	
	
	
	
	string choose_behavior(float satisfaction_factor, float uncertainty_factor){
		
//TODO set agent scolor in the main model		
		if (satisfaction_factor > 0.5) and (uncertainty_factor <= 0.5){
			return "repeat";
		} else if (satisfaction_factor > 0.5) and (uncertainty_factor > 0.5){
			return "imitate";
		} else if (satisfaction_factor <= 0.5) and (uncertainty_factor <= 0.5){
			return "optimize";
		}
					
		return "inquire";
	}
	
	
	float get_linear_forecast(list<float> f, int mode_number){
		
		matrix<float> data_matrix <- 0.0 as_matrix {2,length(f)};
		loop i from: 0 to: length(f) -1 {
			
			data_matrix[1,i] <- i;
			
			data_matrix[0,i] <- f[i];
		}
		//write data_matrix;
		if mode_number = ""{
			warn "No mode defined in the call to linear forecast";
		}
		regression my_regression_model  <- build(data_matrix);
		//write my_regression_model;
		float my_prediction <-  predict(my_regression_model, [length(f)]);
		//write "i am inhabitant"+ int(self)+ " using mode " + string(mode_number) + "_ " + my_prediction;
		return my_prediction;
	}
	
	
	
	
}





