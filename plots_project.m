table1_raw = readtable('output/net_stats.csv');
table2_raw = readtable('output/ami_vals.csv');

t1_labels = convertCharsToStrings(table2array(table1_raw(:,1)));
t1_data = table2array(table1_raw(:,2:end));

trans_ind = ~contains(t1_labels,".");
social_ind = contains(t1_labels,".");

trans_data = t1_data(trans_ind,:);
social_data = t1_data(social_ind,:);
social_on_data = social_data(1:14,:);
social_off_data = social_data(15:end,:);

num_t=size(trans_data,1);
num_sn=size(social_on_data,1);
num_sf=size(social_off_data,1);

%Box & Whisker plots for each algorithm
for i=[1,2,3,4]
    C = [trans_data(:,6+i)' social_on_data(:,6+i)' social_off_data(:,6+i)'];
    grp = [repmat(["Transportation"],num_t,1)' repmat(["Social (Online)"], ...
        num_sn,1)' repmat(["Social (Offline)"],num_sf,1)'];
    
    fig = figure(i);
    plot1 = boxplot(C,grp);
    hold on;
    xlabel('Category');
    ylabel('Modularity');
    title_strings = ["Modularity Distributions (Louvain)",
        "Modularity Distributions (Karrer-Newman)",
        "Modularity Distributions (Newman-Reinert)",
        "Modularity Distributions (Infomap)"];
    title(title_strings(i));
    fontsize(fig,scale=1.5);
end



%Modularity vs Number of Blocks
for i=[1,2,3,4]
    mods1 = trans_data(:,6+i)';
    mods2 = social_on_data(:,6+i)';
    mods3 = social_off_data(:,6+i)';

    parts1 = trans_data(:,2+i)';
    parts2 = social_on_data(:,2+i)';
    parts3 = social_off_data(:,2+i)';

    fig = figure(4+i);
    scatter(parts1,mods1,'filled');
    hold on;
    scatter(parts2,mods2,'filled');
    scatter(parts3,mods3,[],[0.4940 0.1840 0.5560],'filled');
    %if i == 1 || i == 4
    set(gca,'xscale','log');
    %end
    xlabel('Number of Communities');
    ylabel('Modularity');
    title_strings = ["Modularity vs Partition Size (Louvain)",
        "Modularity vs Partition Size (Karrer-Newman)",
        "Modularity vs Partition Size (Newman-Reinert)",
        "Modularity vs Partition Size (Infomap)"];
    title(title_strings(i));
    legend("Transportation", "Social (Online)", "Social (Offline)");
    legend('Location','northeastoutside');
    R = corrcoef([parts1 parts2 parts3],[mods1 mods2 mods3]);
    R(1,2)
    R1 = corrcoef(parts1,mods1);
    R1(1,2)
    R2 = corrcoef(parts2,mods2);
    R2(1,2)
    R3 = corrcoef(parts3,mods3);
    R3(1,2)
    fontsize(fig,scale=1.5);
end


%Size of networks (edges vs nodes)
nodes_t = trans_data(:,1)';
nodes_sn = social_on_data(:,1)';
nodes_sf = social_off_data(:,1)';

edges_t = trans_data(:,2)';
edges_sn = social_on_data(:,2)';
edges_sf = social_off_data(:,2)';

fig = figure(9);
scatter(nodes_t,edges_t,'filled');
hold on;
scatter(nodes_sn,edges_sn,'filled');
scatter(nodes_sf,edges_sf,[],[0.4940 0.1840 0.5560],'filled');
set(gca,'xscale','log');
set(gca,'yscale','log');


xlabel('Number of Nodes');
ylabel('Number of Edges');
title("Size of Networks");
legend("Transportation", "Social (Online)", "Social (Offline)");
legend('Location','northeastoutside');
fontsize(fig,scale=1.5);

%Average degree vs modularity
for i=[1,2,3,4]
    mods1 = trans_data(:,6+i)';
    mods2 = social_on_data(:,6+i)';
    mods3 = social_off_data(:,6+i)';

    meank1 = edges_t./nodes_t;
    meank2 = edges_sn./nodes_sn;
    meank3 = edges_sf./nodes_sf;

    fig = figure(9+i);
    scatter(meank1,mods1,'filled');
    hold on;
    scatter(meank2,mods2,'filled');
    scatter(meank3,mods3,[],[0.4940 0.1840 0.5560],'filled');
    %if i == 1 || i == 4
    set(gca,'xscale','log');
    %end
    xlabel('Average Degree');
    ylabel('Modularity');
    title_strings = ["Modularity vs Average Degree (Louvain)",
        "Modularity vs Average Degree (Karrer-Newman)",
        "Modularity vs Average Degree (Newman-Reinert)",
        "Modularity vs Average Degree (Infomap)"];
    title(title_strings(i));
    legend("Transportation", "Social (Online)", "Social (Offline)");
    legend('Location','northeastoutside');
    R = corrcoef([meank1 meank2 meank3],[mods1 mods2 mods3]);
    R(1,2)
    fontsize(fig,scale=1.5);
end


t2_labels = convertCharsToStrings(table2array(table2_raw(:,1)));
t2_data = table2array(table2_raw(:,2:end));

trans_ind2 = ~contains(t2_labels,".");
social_ind2 = contains(t2_labels,".");

trans_ami = t2_data(trans_ind2,:);
social_ami = t2_data(social_ind2,:);
social_on_ami = social_ami(1:14,:);
social_off_ami = social_ami(15:end,:);

num_t2=size(trans_ami,1);
num_sn2=size(social_on_ami,1);
num_sf2=size(social_off_ami,1);

trans_ami_matrix = reshape(mean(trans_ami),4,4);
social_on_ami_matrix = reshape(mean(social_on_ami),4,4);
social_off_ami_matrix = reshape(mean(social_off_ami),4,4);
total_ami_matrix = reshape(mean([trans_ami;social_on_ami;social_off_ami]),4,4);

%AMi heatmap
fig = figure(14);
heatmap(total_ami_matrix,'XData',["Louvain" "KN" "NR" "Infomap"], ...
    'YData',["Louvain" "KN" "NR" "Infomap"]);
title("Average Pairwise AMI")
fontsize(fig,scale=1.5);

%AMI means
trans_ami_sums = (sum(trans_ami,2)-4)./12;
social_on_ami_sums = (sum(social_on_ami,2)-4)./12;
social_off_ami_sums = (sum(social_off_ami,2)-4)./12;

C2 = [trans_ami_sums' social_on_ami_sums' social_off_ami_sums'];
grp2 = [repmat(["Transportation"],num_t2,1)' repmat(["Social (Online)"], ...
        num_sn2,1)' repmat(["Social (Offline)"],num_sf2,1)'];

fig = figure(15);
boxplot(C,grp);
hold on;
xlabel('Category');
ylabel('Mean AMI');
title("AMI Aggregates");
fontsize(fig,scale=1.5);

%Number of communities vs number of nodes/edges
color_list = [[0 0.4470 0.7410];
    [0.8500 0.3250 0.0980];
    [0.4940 0.1840 0.5560];
    [0.4660 0.6740 0.1880]
    ];
fig = figure(16);

for i=[1,2,3,4]
    parts1 = trans_data(:,2+i)';
    parts2 = social_on_data(:,2+i)';
    parts3 = social_off_data(:,2+i)';

    nodes1 = trans_data(:,1)';
    nodes2 = social_on_data(:,1)';
    nodes3 = social_off_data(:,1)';

    scatter([nodes1 nodes2 nodes3],[parts1 parts2 parts3],[],color_list(i,:),'filled');
    hold on;
end

xl = xlim;
fplot(@(x) sqrt(x),[xl(1) xl(2)],'Color','k');
xlabel('Total Nodes');
ylabel('Number of Communities');
title("Detected Community Size");
legend("Louvain", "Karrer-Newman", "Newman-Reinert", "Infomap");
legend('Location','northeastoutside');
set(gca,'xscale','log');
set(gca,'yscale','log');
fontsize(fig,scale=1.5);

fig = figure(17);
for i=[1,2,3,4]
    parts1 = trans_data(:,2+i)';
    parts2 = social_on_data(:,2+i)';
    parts3 = social_off_data(:,2+i)';

    edges1 = trans_data(:,2)';
    edges2 = social_on_data(:,2)';
    edges3 = social_off_data(:,2)';

    scatter([edges1 edges2 edges3],[parts1 parts2 parts3],[],color_list(i,:),'filled');
    hold on;
end

xl = xlim;
fplot(@(x) sqrt(x),[xl(1) xl(2)],'Color','k');
xlabel('Total Edges');
ylabel('Number of Communities');
title("Detected Community Size");
legend("Louvain", "Karrer-Newman", "Newman-Reinert", "Infomap");
legend('Location','northeastoutside');
set(gca,'xscale','log');
set(gca,'yscale','log');
fontsize(fig,scale=1.5);


fig = figure(18);
Xs = [];
for i=[1,2,3,4]
    parts1 = trans_data(:,2+i)';
    parts2 = social_on_data(:,2+i)';
    parts3 = social_off_data(:,2+i)';
    xs = [parts1 parts2 parts3];
    Xs = [Xs;xs];
end
hist(Xs');

xlabel('Frequency');
ylabel('Number of Communities');
title("Histogram (with Infomap)");
legend("Louvain", "Karrer-Newman", "Newman-Reinert", "Infomap");
legend('Location','northeastoutside');
fontsize(fig,scale=1.5);

fig = figure(19);
Xs = [];
for i=[1,2,3]
    parts1 = trans_data(:,2+i)';
    parts2 = social_on_data(:,2+i)';
    parts3 = social_off_data(:,2+i)';
    xs = [parts1 parts2 parts3];
    Xs = [Xs;xs];
end
hist(Xs');

xlabel('Frequency');
ylabel('Number of Communities');
title("Histogram (without Infomap)");
legend("Louvain", "Karrer-Newman", "Newman-Reinert");
legend('Location','northeastoutside');
fontsize(fig,scale=1.5);

