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
		
//TODO set color in the main model		
		if (satisfaction_factor > 0.5) and (uncertainty_factor <= 0.5){
			return "repeat";
		} else if (satisfaction_factor > 0.5) and (uncertainty_factor > 0.5){
			return "imitate";
		} else if (satisfaction_factor <= 0.5) and (uncertainty_factor <= 0.5){
			return "optimize";
		}
					
		return "inquire";
	}
	
	
	
	
}





