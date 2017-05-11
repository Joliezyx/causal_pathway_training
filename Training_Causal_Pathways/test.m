% % update training datasets datasets for new iteration of EM
% ST_candidates_new = cell(K,1); 
% transfer_entropy = [];
% for kk = 1:K
%     ST_candidates_new{kk}=ST_candidates{1,iter,season};
%     ind_k = find(p2(:,kk)==1);
%     temp_X = All(ind_k,2);
%     
%     for i = 1:length(ST_candidates{1,iter,season})
%         temp_Y_id = ST_candidates{1,iter,season}(i);
%         Granger_test_mark = 1;
%         for update_p = 1:6           
%             temp_Y = diff(City_Level_UD(Window,1+update_p,temp_Y_id));
%             Granger_test = regress_residuals_Gaussian_shorter(temp_X,temp_Y(ind_k),10); % time tags
% %             figure;
% % %             plot(Granger_test);
% %             if max(Granger_test) > Granger_test_mark 
% %                 [~, granger_max_ind] = max(Granger_test);
% %                 granger_max_ind = granger_max_ind(1);
% %                 ST_candidates_new{kk}(i,:) = [temp_Y_id,update_p,max(Granger_test)];
% %                 Granger_test_mark = max(Granger_test);       
% %             end
% %             
% %         end
% %         if max(Granger_test) <= 1 
% %             ST_candidates_new{kk}(i,:) = [temp_Y_id,1,0]; % change p_type_target later
% %         end
% %     end
% % 
% %     Cond_entropy = Cond_entropy + ST_candidates_new{kk}(:,3);
% %     p_type = [p_type ST_candidates_new{kk}(:,2)];
% %     transfer_entropy = [transfer_entropy ST_candidates_new{kk}(:,3)];
% %     
% %     
% % 
% % end
% % 
% % 
% %  [~,tr_en_ind] = max(transfer_entropy,[],2);
% % for i = 1:length(tr_en_ind)
% %     ST_candidates{1,iter,season}(i,2:3) = [p_type(i,tr_en_ind(i)),Cond_entropy(i)];
% % end
% % 
% % [value order]= sort(ST_candidates{1,iter,season}(:,3),'descend');
% % candidates_city_by_order_new = ST_candidates{1,iter,season}(order(1:Candidate_Num),1);
% % if candidates_city_by_order_new == candidates_city_by_order
% %     break
% % end
% % P_Value = [City_Level_UD(Window,2:7,iter) reshape(City_Level_UD(Window,2:7,candidates_city_by_order),[],Candidate_Num*6)];
% % P_Value_test = [City_Level_UD(Window_test,2:7,iter) reshape(City_Level_UD(Window_test,2:7,candidates_city_by_order),[],Candidate_Num*6)];
% % E_Value = City_Level_Weather_Training{iter}(Window,:);
% % E_Value_test = City_Level_Weather_Training{iter}(Window_test,:);
% % P_Training = lagmatrix(diff(P_Value,1),1:Tlag);
% % E_Training = lagmatrix(diff(E_Value,1),0:Tlag);
% % P_Test = lagmatrix(diff(P_Value_test,1),1:Tlag);
% % E_Test = lagmatrix(diff(E_Value_test,1),0:Tlag);
% figure;
% Beijing = City_Level_Weather_Training{1};
% trainingData = Beijing;
% trainingData(any(isnan(trainingData),2),:) = [];
% [coeff,score] = pca(trainingData);
% column = 1:40;
% indices = randperm(length(column));
% Beijing2D = trainingData*score(:,column(indices(1:2)));
% Beijing2D = trainingData*score(:,[5,17]);
% K = 7;
% color_list = {'k','m','b','y','g','c','r'};
% maker_list = {'^','o','p','d','*','h','s'};
% %ind = kmeans(Beijing2D,K);
% ind = clusterdata(Beijing2D,'distance','euclidean','linkage', 'centroid','maxclust',K);
% 
% for k = 1:K
%     if k == 1 || k == 5
%         continue;
%     end
%     X = Beijing2D(ind==k,1);
%     Y = Beijing2D(ind==k,2);
%     %Z = Beijing2D(ind==k,3);
%     scatter(X(1:30:length(X)),Y(1:30:length(Y)),maker_list{k},'MarkerEdgeColor','k','MarkerFaceColor',color_list{k});
%     hold on;
% end
% grid on;
% box on;
% column(indices(1:2))
% legend ('Cluster 1', 'Cluster 2','Cluster 3','Cluster 4','Cluster 5')
%     



% p2_test = zeros(length(P_Test),K);
% evidence = cell(5,1);
% for i=1:length(P_Test);
%     evidence{3}=P0_Test(i,p)';
%     evidence{5}=P_Test(i,:)';
%     evidence{4}=E_Test(i,:)';
%     [engine4, ll] = enter_evidence(engine2,evidence);
%     marg = marginal_nodes(engine4,2);
%     p2_test(i,:)=marg.T';    
% end
% p2_test = round(p2_test);
% filename = strcat('N',num2str(N),'K',num2str(K),'.csv');
% csvwrite(filename,p2_test);
% 
% calcalate the precision on the test data
% precision = zeros(K,1);
% error = zeros(K,Pollutants_Type);
% for k = 1:K
%     ind_k = find(p2(:,kk)==1);
%     if length(ind_k) < 3
%         error(k,1) = NaN;
%         continue;
%     end
%     [b1 bint r] = regress(All(ind_k,p+1),P_Training(ind_k,:));
%     ind_k_test = find(p2_test(:,k)==1);
%     ind_k_test = union(ind_k_test,find(all(p2_test==0,2)));
%     %[b2 bint r] = regress(P0_Test(ind_k_test,p),P_Test(ind_k_test,:));
%     ground_truth_diff = P0_Test(ind_k_test,p);
%     r_new = ground_truth_diff - P_Test(ind_k_test,:)*b1;
%     %ground_truth_diff(ground_truth_diff == 0) = nanmean(ground_truth_diff);
%     error(k,1) = nanmean(abs(r_new./(ground_truth_diff+P_Value_test(ind_k_test,p))));
%     precision(k,1) = 1 - error(k,1);
%     
% end
% Precision{K,N} = nanmean(precision);
% precision
clc;
load City_Index.mat
N = 5;
K = 7;
Accuracy_region = zeros(K,N,3);
count_region = zeros(K,N,3);
for ave_iter = 1:3
    for p = 1:1
        for test_iter = 1:60 %128
            for j = 1:4
                filename = strcat('./Result/Accuracy/Season_',num2str(j),'_City_',num2str(test_iter),'_Pollutant_',num2str(p),'_AveNo_',num2str(ave_iter),'.csv');
                d=struct(dir(filename));
                if exist(filename, 'file') ==0 
                    continue;
                end
                if d.bytes == 0 
                    continue;
                end
                accuracy = csvread(filename);
                accuracy(accuracy <= 0) = 0;

%                 if size(accuracy,1) ~= K || size(accuracy,2) ~= N
%                     continue;
%                 end
                for test_city_index = 1:3
                    if ismember(test_iter,City_Index{test_city_index});
                        Accuracy_region(:,:,test_city_index) = Accuracy_region(:,:,test_city_index) + accuracy;
                        count_region(:,:,test_city_index) = count_region(:,:,test_city_index) + (accuracy > 0);
                        
                    end
                end
            end
        end
    end
end
Accuracy_final = zeros(3*K,N);

for test_city_index = 1:3
    Accuracy_final(test_city_index:3:3*K,:)= Accuracy_region(:,:,test_city_index)./ count_region(:,:,test_city_index);
    %nanmean(Accuracy_region(:,:,test_city_index)./ count_region(:,:,test_city_index))
end

Accuracy_final
