# causal_pathway_training
Causal pathway training is the core part for learning the pg-Causality model from paper https://www.microsoft.com/en-us/research/wp-content/uploads/2017/07/pg-Causality-yuzheng.pdf. 


pg-Causality is an efficient pattern-aided Bayesian-based causal structure learning approach for identifying the causalities among different air pollutants in the spatio-temporal space. The published codes identified the causality for air pollution in China (North China, Yangtze River Delta, and Pearl River Delta) 

How to Run:
1.	Unzip bnt.zip (Matlab Bayesian toolbox) to the main directory.
2.	Download .mat files as large files from github (not directly download from the webpage).
3.	Run zhc_Main.m for training the structure and the parameters of the causality model for air pollution.
4.	Result (statistics causal inference: absolute error, accuracy, as well as the intermediate structure infos) will be put into the folder ./Result/
5.	Run accuracy_statistics_all.m to get the final statistics of the inference accuracy regarding to all the cities.

Data description:
1.	City_Level_UD_Interp_New.mat: Hourly air quality data (PM2.5, PM10, NO2, CO, O3, SO2) from 128 cities. Time range: 06/01/2013 - 12/31/2016. 
2.	City_Level_Weather_Training.mat: Hourly weather factor features for 128 cities. Regarding each city, the features are calculated from five basic meteorological information, i.e. temperature (T), pressure (P), humidity (U), wind speed (WS), and wind direction (WD), uniformly divided into 9 grids in the whole region. Therefore the features for each city are 45-dimensional by default. The dimension could be less than 45 if there’s no weather data contained in a grid.
3.	CityInfo.mat: GPS info for 128 cities
4.	City_Index.mat: Which region each city belongs to
5.	ST_candidates_v1_new.mat: spatial candidates generated from pattern mining module
6.	ST_candidates_v2_new.mat: spatial candidates generated without pattern mining module (with only Granger causality)
7.	ind_season_new.mat: indices for temporally separating datasets 1) in each season, 2) as training datasets or testing datasets.

Major functions:
1.	zhc_Main.m: Main function
2.	GC_Score.m: Get the Granger causality score for two air pollutants at two different locations.
3.	Make_Q_Data.m: Generate the features for the training causal network, based on selected candidate cities.
4.	Train_Network.m: Train the Gaussian Bayesian network.
5.	Change_Structure.m: Refine the casual structure with the trained dependency parameters from (Train_Network.m) in last step.
6.	accuracy_statistics_all.m: Accuracy calculation for 128 cities.


Some major results:

1.	Optimal accuracy for 128 cities respected to K (# of clusters), and N (# of neighbor cities that may influence the target city).
 
2.	By choosing the optimal K and N for each city, we draw and concatenate the causal pathways for Beijing PM2.5: Which shows the pollutants are more likely to come from the south-west and north-east. Btw, the cliques in the causal pathways correspond to the locations of major plants in North China. 
   

