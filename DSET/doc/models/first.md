
# File first.gaml


------


## Index

### Species (4)

-  [buildings](#species-buildings) (species)
-  [inhabitants](#species-inhabitants) (species)
-  [roads](#species-roads) (species)
-  [study_area](#species-study_area) (species)


### Experiments (1)

-  [Main Model](#experiment-Main Model-gui-) (gui)

------


## Species


### Species World


> Name: model1
Author: Srirama Bhamidipati
Description:
Tags: Tag1, Tag2, TagN
draw string("Off_" + int(self)) color: # white font: font('Helvetica Neue', 12, # bold + # italic);



#### Micro species

-  [buildings](#species-buildings)
-  [roads](#species-roads)
-  [study_area](#species-study_area)
-  [inhabitants](#species-inhabitants)


#### Attributes
<table><tr><th>Type</th><th>Name</th></tr><tr><td>date</td><td>starting_date <br/> </td><tr><td>float</td><td>step <br/> </td><tr><td>file</td><td>shape_file_streets <br/> </td><tr><td>file</td><td>shape_file_bounds <br/> </td><tr><td>file</td><td>shape_buildings <br/> </td><tr><td>geometry</td><td>shape <br/> </td><tr><td>float</td><td>proportion_of_offices <br/> </td><tr><td>float</td><td>distance_between_homes <br/> </td><tr><td>float</td><td>relative_work_work_distance <br/> </td><tr><td>int</td><td>inhabitant_population <br/> </td><tr><td>float</td><td>max_travel_mode_difference <br/> </td><tr><td>graph</td><td>g <br/> </td><tr><td>float</td><td>inhabitant_relative_importance_existence_need <br/> </td><tr><td>float</td><td>inhabitant_relative_importance_social_need <br/> </td><tr><td>float</td><td>inhabitant_relative_importance_personal_need <br/> </td><tr><td>list</td><td>work_pt_km <br/> </td><tr><td>list</td><td>work_auto_km <br/> </td><tr><td>list</td><td>work_bike_km <br/> </td><tr><td>list</td><td>work_pt_min <br/> </td><tr><td>list</td><td>work_auto_min <br/> </td><tr><td>list</td><td>work_bike_min <br/> </td><tr><td>list</td><td>modes <br/>  ``` Insert the global definitions, variables and actions here ```  </td><tr><td>map</td><td>mode_speed_string <br/> </td><tr><td>map</td><td>mode_speed_int <br/> </td><tr><td>map</td><td>mode_value <br/> </td></table>


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


 using skills moving


#### Micro species



#### Attributes
<table><tr><th>Type</th><th>Name</th></tr><tr><td>float</td><td>ambition_level <br/> </td><tr><td>float</td><td>uncertainty_tolerance_level <br/> </td><tr><td>int</td><td>cognitive_effort <br/> </td><tr><td>float</td><td>my_aspiration <br/> </td><tr><td>string</td><td>my_mode_preferred <br/> </td><tr><td>string</td><td>my_mode_actual <br/> </td><tr><td>int</td><td>value_mode_preferred <br/> </td><tr><td>int</td><td>value_mode_actual <br/> </td><tr><td>float</td><td>my_travel_distance <br/> </td><tr><td>float</td><td>my_travel_time <br/> </td><tr><td>list</td><td>my_peers <br/> </td><tr><td>bool</td><td>has_peers <br/> </td><tr><td> [buildings](#species-buildings)</td><td>my_home <br/> </td><tr><td>point</td><td>location <br/> </td><tr><td> [buildings](#species-buildings)</td><td>my_office <br/> </td><tr><td>float</td><td>my_need_social <br/> </td><tr><td>float</td><td>my_need_personal <br/> </td><tr><td>float</td><td>my_need_existence <br/> </td><tr><td>float</td><td>my_overall_needs_satisfaction <br/> </td><tr><td>float</td><td>superior_to_peers_ratio <br/> </td><tr><td>float</td><td>inhabitant_existence_need_satisfaction <br/> </td><tr><td>float</td><td>inhabitant_overall_need_satisfaction_aspiration_level_ratio <br/> </td><tr><td>map</td><td>my_uncertainty <br/> </td><tr><td>float</td><td>inhabitant_uncertainty_ratio <br/> </td><tr><td>list</td><td>memory_bike_times <br/> </td><tr><td>list</td><td>memory_walk_times <br/> </td><tr><td>list</td><td>memory_pt_times <br/> </td><tr><td>list</td><td>memory_car_times <br/> </td><tr><td>map</td><td>mode_specific_memory <br/> </td><tr><td>list</td><td>memory_all_modes <br/> </td><tr><td>map</td><td>my_expected_travel_time_all_modes <br/> </td><tr><td>map</td><td>my_uncertainty_travel_time_all_modes <br/> </td><tr><td>float</td><td>avg_my_last_5_days_travel_time <br/> </td><tr><td>float</td><td>my_last_day_travel_time <br/> </td><tr><td>float</td><td>overall_need_satisfaction_aspiration_level_ratio <br/> </td><tr><td>float</td><td>uncertainty_tolerance_level_ratio <br/> </td><tr><td>string</td><td>my_behavior <br/> </td><tr><td>list</td><td>my_optimize_all_mode <br/> </td><tr><td>map</td><td>inquiry_per_mode <br/> </td><tr><td>list</td><td>inhabitant_expected_relative_travel_speed_travel_mode <br/> </td><tr><td>float</td><td>inhabitant_potential_existence_need_satisfaction <br/> </td><tr><td>float</td><td>inhabitant_potential_social_need_satisfaction_travel <br/> </td><tr><td>float</td><td>inhabitant_potential_personal_need_satisfaction_travel <br/> </td></table>


#### Actions
<table><tr><th>Type</th><th>Name</th></tr><tr><td>list</td><td> get_peers(list possible_peers,float home_distance,float office_office_distance) <br/> </td></tr><tr><td>float</td><td> calculate_similarity(,list _peers) <br/> </td></tr><tr><td>float</td><td> calculate_superiority(,list _peers) <br/> </td></tr><tr><td></td><td> calculate_social_need_satisfaction() <br/> </td></tr><tr><td>float</td><td> calculate_personal_need_satisfaction() <br/> </td></tr><tr><td></td><td> calculate_existence_need_satisfaction(, [inhabitants](#species-inhabitants) i) <br/> </td></tr><tr><td></td><td> calculate_overall_need_satisfaction() <br/> </td></tr><tr><td></td><td> calculate_relative_overall_need_satisfaction() <br/> </td></tr><tr><td></td><td> assign_initial_cognitive_memory() <br/> </td></tr><tr><td>float</td><td> get_expected_travel_time_for_a_mode(, [inhabitants](#species-inhabitants) i,int mode) <br/> </td></tr><tr><td>map</td><td> get_expected_travel_time_for_all_modes(, [inhabitants](#species-inhabitants) i) <br/> </td></tr><tr><td>map</td><td> get_uncertainty_travel_time_for_all_modes(, [inhabitants](#species-inhabitants) i) <br/> </td></tr><tr><td></td><td> calculate_ratio_uncertainty_uncertainty_tolerance_level(,string s) <br/> </td></tr><tr><td>int</td><td> imitates(, [inhabitants](#species-inhabitants) i) <br/> </td></tr><tr><td>int</td><td> repeats(, [inhabitants](#species-inhabitants) i) <br/> </td></tr><tr><td>int</td><td> inquires(, [inhabitants](#species-inhabitants) i) <br/> </td></tr><tr><td>int</td><td> optimizes(, [inhabitants](#species-inhabitants) i) <br/> </td></tr><tr><td>float</td><td> sub_potential_PERSONAL_need_satisfaction(, [inhabitants](#species-inhabitants) i,int mode) <br/> </td></tr><tr><td>float</td><td> sub_potential_SOCIAL_need_satisfaction(, [inhabitants](#species-inhabitants) i,int mode) <br/> </td></tr><tr><td>float</td><td> sub_potential_EXISTENCE_need_satisfaction(, [inhabitants](#species-inhabitants) i,int mode) <br/> </td></tr><tr><td>float</td><td> sub_potential_OVERALL_need_satisfaction(, [inhabitants](#species-inhabitants) i,int mode) <br/> </td></tr></table>


#### Reflexes
<table><tr><th>Type</th><th>Name</th></tr><tr><td>reflex</td><td> movement <br/> </td><tr><td>init</td><td> null <br/> </td></table>


#### Aspects

- a
- b


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



### Experiment Main Model (gui)




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
    - b ( [inhabitants](#species-inhabitants))