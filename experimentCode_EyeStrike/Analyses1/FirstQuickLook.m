% Pilot Results:
% Claculate the temporal difference between the target and the
% interception: How much too early / too late was intercepted:



for i = 1:576
   
    
   veridical_reapp(i) = find(Experiment.const.INTERP_TXY{Experiment.trialData.blockConditions(i)}(:,2) >= Experiment.const.OccluderSizeX(Experiment.trialData.occluder(i)), 1, 'first');
   intercept_reapp(i) = Experiment.trialData.t_intercept_VBL(i,1)*1000 - Experiment.trialData.t_start_VBL(i,1)*1000;
   
   
   tempError(i) = veridical_reapp(i) - intercept_reapp(i);
    
end



% 200 0
pt500acc0 = Experiment.trialData.blockConditions(:) == 1;
tmpError500_0 = tempError(pt500acc0);

% 200 -8
pt500accn8 = Experiment.trialData.blockConditions(:) == 2;
tmpError500_n8 = tempError(pt500accn8);

% 200 +8
pt500accp8 = Experiment.trialData.blockConditions(:) == 3;
tmpError500_p8 = tempError(pt500accp8);

% % 800 0
% pt800acc0 = Experiment.trialData.blockConditions(:) == 4;
% tmpError800_0 = tempError(pt800acc0);
% 
% % 800 -8
% pt800accn8 = Experiment.trialData.blockConditions(:) == 5;
% tmpError800_n8 = tempError(pt800accn8);
% 
% % 800 +8
% pt800accp8 = Experiment.trialData.blockConditions(:) == 6;
% tmpError800_p8 = tempError(pt800accp8);




counter = 1;
for i = 1:12:192
    tmpError1(counter,1:12) = tmpError500_0(i:i+11);
    tmpError2(counter,1:12) = tmpError500_n8(i:i+11);
    tmpError3(counter,1:12) = tmpError500_p8(i:i+11);
    
    counter = counter + 1;
end


for i = 1:12
    for j = 1:16
        if tmpError1(j,i) > 450 || tmpError1(j,i) < -450
            tmpError1(j,i) = NaN;
        end
    end
end

for i = 1:12
    for j = 1:16
        if tmpError2(j,i) > 450 || tmpError2(j,i) < -450
            tmpError2(j,i) = NaN;
        end
    end
end

for i = 1:12
    for j = 1:16
        if tmpError3(j,i) > 450 || tmpError3(j,i) < -450
            tmpError3(j,i) = NaN;
        end
    end
end
        
% for i = 1:12
%     for j = 1:8
%         if tmpError4(j,i) > 250 || tmpError4(j,i) < -250
%             tmpError4(j,i) = NaN;
%         end
%     end
% end
% 
% for i = 1:12
%     for j = 1:8
%         if tmpError5(j,i) > 250 || tmpError5(j,i) < -250
%             tmpError5(j,i) = NaN;
%         end
%     end
% end
% 
% for i = 1:12
%     for j = 1:8
%         if tmpError6(j,i) > 250 || tmpError6(j,i) < -250
%             tmpError6(j,i) = NaN;
%         end
%     end
% end




figure(1)
plot(nanmean(tmpError1(:,1:8),1),'--ok')
hold
plot(nanmean(tmpError2(:,1:8),1),'--or')
plot(nanmean(tmpError3(:,1:8),1),'--og')
% plot(nanmean(tmpError4(:,1:8),1),'-ok')
% plot(nanmean(tmpError5(:,1:8),1),'-or')
% plot(nanmean(tmpError6(:,1:8),1),'-og')


%% for test trials:

% test occluder 2:
% 200 0
acc0_occ2 = find(Experiment.trialData.blockConditions(:) == 1 & Experiment.trialData.occluder(:) == 2);
tmpError0_occ2 = tempError(acc0_occ2);

acc0_occ3 = find(Experiment.trialData.blockConditions(:) == 1 & Experiment.trialData.occluder(:) == 3);
tmpError0_occ3 = tempError(acc0_occ3);

acc0_occ4 = find(Experiment.trialData.blockConditions(:) == 1 & Experiment.trialData.occluder(:) == 4);
tmpError0_occ4 = tempError(acc0_occ4);

acc0_occ5 = find(Experiment.trialData.blockConditions(:) == 1 & Experiment.trialData.occluder(:) == 5);
tmpError0_occ5 = tempError(acc0_occ5);

% 200 -8
accn8_occ2 = find(Experiment.trialData.blockConditions(:) == 2 & Experiment.trialData.occluder(:) == 2);
tmpErrorn8_occ2 = tempError(accn8_occ2);

accn8_occ3 = find(Experiment.trialData.blockConditions(:) == 2 & Experiment.trialData.occluder(:) == 3);
tmpErrorn8_occ3 = tempError(accn8_occ3);

accn8_occ4 = find(Experiment.trialData.blockConditions(:) == 2 & Experiment.trialData.occluder(:) == 4);
tmpErrorn8_occ4 = tempError(accn8_occ4);

accn8_occ5 = find(Experiment.trialData.blockConditions(:) == 2 & Experiment.trialData.occluder(:) == 5);
tmpErrorn8_occ5 = tempError(accn8_occ5);

% 200 +8
accp8_occ2 = find(Experiment.trialData.blockConditions(:) == 3 & Experiment.trialData.occluder(:) == 2);
tmpErrorp8_occ2 = tempError(accp8_occ2);

accp8_occ3 = find(Experiment.trialData.blockConditions(:) == 3 & Experiment.trialData.occluder(:) == 3);
tmpErrorp8_occ3 = tempError(accp8_occ3);

accp8_occ4 = find(Experiment.trialData.blockConditions(:) == 3 & Experiment.trialData.occluder(:) == 4);
tmpErrorp8_occ4 = tempError(accp8_occ4);

accp8_occ5 = find(Experiment.trialData.blockConditions(:) == 3 & Experiment.trialData.occluder(:) == 5);
tmpErrorp8_occ5 = tempError(accp8_occ5);






plot(12, mean(nanmean(tmpError1(:,9:12),1),'ok'))
plot(12, mean(nanmean(tmpError2(:,9:12),1),'or'))
plot(12, mean(nanmean(tmpError3(:,9:12),1),'og'))

plot(12, mean(nanmean(tmpError4(:,9:12),1),'*k'))
plot(12, mean(nanmean(tmpError5(:,9:12),1),'*r'))
plot(12, mean(nanmean(tmpError6(:,9:12),1),'*g'))

% plot(12, nanmean(tmpError2(:,9:8)),'--or')
% plot(12, nanmean(tmpError3(:,1:8)),'--og')
% plot(12, nanmean(tmpError4(:,1:8)),'-ok')
% plot(12, nanmean(tmpError5(:,1:8)),'-or')
% plot(12, nanmean(tmpError6(:,1:8)),'-og')