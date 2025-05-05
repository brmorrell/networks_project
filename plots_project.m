table1_raw = readtable('louvain_mod.csv');


trans = table2array(table1_raw(1:20,2));
social = table2array(table1_raw(21:end,2));

t_mean = mean(trans);
s_mean = mean(social);

C = [trans' social'];
grp = [repmat(["Transportation"],20,1)' repmat(["Social"],11,1)'];

figure(1);
plot1 = boxplot(C,grp);
hold on;
xlim([0,3]);
xlabel('Domain');
ylabel('Modularity');
title('Maximum Modularity Comparison');

