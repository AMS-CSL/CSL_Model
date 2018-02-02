 
 # File first.gaml 
  
  
 ------ 
  
  
 ## Index 
  
 ### Species (4) 
  
 -  [buildings](#species-buildings) (species) 
 -  [inhabitants](#species-inhabitants) (species) 
 -  [roads](#species-roads) (species) 
 -  [study_area](#species-study_area) (species) 
  
  
 ### Experiments (1) 
  
 -  [model1](#experiment-model1-gui-) (gui) 
  
 ------ 
  
  
 ## Species 
  
  
 ### Species World 
  
  
 > Name: model1
Author: Ram
Description:
Tags: Tag1, Tag2, TagN
draw string("Off_" + int(self)) color: # white font: font('Helvetica Neue', 12, # bold + # italic); 
  
  
  
 #### Micro species 
  
 -  [buildings](#species-buildings) 
 -  [roads](#species-roads) 
 -  [study_area](#species-study_area) 
 -  [inhabitants](#species-inhabitants) 
  
  
 #### Attributes 
 <table><tr><th>Type</th><th>Name</th></tr><tr><td>file</td><td>shape_file_streets <br/> </td><tr><td>file</td><td>shape_file_bounds <br/> </td><tr><td>file</td><td>shape_buildings <br/> </td><tr><td>geometry</td><td>shape <br/> </td><tr><td>float</td><td>proportion_of_offices <br/> </td><tr><td>float</td><td>distance_between_homes <br/> </td><tr><td>float</td><td>relative_work_work_distance <br/> </td><tr><td>int</td><td>inhabitant_population <br/> </td><tr><td>list</td><td>modes <br/>  ``` Insert the global definitions, variables and actions here ```  </td><tr><td>map</td><td>mode_speed <br/> </td><tr><td>map</td><td>mode_value <br/> </td></table> 
  
  
 #### Actions 
 </table> 
  
  
 #### Reflexes 
 <table><tr><th>Type</th><th>Name</th></tr><tr><td>init</td><td> null <br/> </td></table> 
  
  
 ### Species buildings 
  
  
  
  
 #### Micro species 
  
  
  
 #### Attributes 
 <table><tr><th>Type</th><th>Name</th></tr><tr><td>string</td><td>use <br/> </td><tr><td>rgb</td><td>my_color <br/> </td></table> 
  
  
 #### Actions 
 </table> 
  
  
 #### Reflexes 
 </table> 
  
  
 #### Aspects 
  
 - a 
 - transparent_frame 
  
  
 ### Species inhabitants 
  
  
  
  
 #### Micro species 
  
  
  
 #### Attributes 
 <table><tr><th>Type</th><th>Name</th></tr><tr><td>string</td><td>mode_preferred <br/> </td><tr><td>string</td><td>mode_actual <br/> </td><tr><td>int</td><td>value_preferred_mode <br/> </td><tr><td>int</td><td>value_actual_mode <br/> </td><tr><td>list</td><td>my_peers <br/> </td><tr><td> [buildings](#species-buildings)</td><td>home <br/> </td><tr><td>point</td><td>location <br/> </td><tr><td> [buildings](#species-buildings)</td><td>office <br/> </td><tr><td>bool</td><td>has_peers <br/> </td><tr><td>float</td><td>need_social <br/> </td><tr><td>float</td><td>need_personal <br/> </td><tr><td>float</td><td>need_existencial <br/> </td><tr><td>float</td><td>diff_mode <br/> </td><tr><td>float</td><td>diff_workplace <br/> </td><tr><td>float</td><td>diff_nearness <br/> </td></table> 
  
  
 #### Actions 
 <table><tr><th>Type</th><th>Name</th></tr><tr><td>list</td><td> assess_peer_differences(list possible_peers,float home_distance,float office_office_distance) <br/> </td></tr><tr><td></td><td> calculate_social_need() <br/> </td></tr><tr><td></td><td> calculate_personal_need() <br/> </td></tr><tr><td></td><td> calculate_existencial_need() <br/> </td></tr></table> 
  
  
 #### Reflexes 
 <table><tr><th>Type</th><th>Name</th></tr><tr><td>init</td><td> null <br/> </td></table> 
  
  
 #### Aspects 
  
 - a 
  
  
 ### Species roads 
  
  
  
  
 #### Micro species 
  
  
  
 #### Attributes 
 </table> 
  
  
 #### Actions 
 </table> 
  
  
 #### Reflexes 
 <table><tr><th>Type</th><th>Name</th></tr><tr><td>init</td><td> null <br/> </td></table> 
  
  
 #### Aspects 
  
 - a 
  
  
 ### Species study_area 
  
  
  
  
 #### Micro species 
  
  
  
 #### Attributes 
 </table> 
  
  
 #### Actions 
 </table> 
  
  
 #### Reflexes 
 </table> 
  
  
 #### Aspects 
  
 - a 
  
 ------ 
  
  
 ## Experiments 
  
  
  
 ### Experiment model1 (gui) 
  
  
  
  
 #### Parameters 
  
 - Proportion of offices in landuse 
 - Total inhabitant population 
 - Work 2 Work distance 
 - Distance between peer homes 
  
  
 #### Attributes 
 <table><tr><th>Type</th><th>Name</th></tr><tr><td>float</td><td>seed <br/> </td></table> 
  
  
 #### Reflexes 
 </table> 
  
  
 #### Actions 
 </table> 
  
  
 #### Displays 
  
 - display d 
     - a ( [study_area](#species-study_area)) 
     - a ( [buildings](#species-buildings)) 
     - a ( [roads](#species-roads)) 
     - a ( [inhabitants](#species-inhabitants))