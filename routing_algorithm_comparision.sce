clc;
clear;
close;

// Load NARVAL toolbox
atomsLoad("NARVAL");

// Node sizes
node_sizes = 5:5:100;

// Time storage
bf_time = zeros(1, length(node_sizes));
dj_time = zeros(1, length(node_sizes));

// Network parameters
L = 1000;
dmax = 120;

disp("ROUTING ALGORITHM COMPARISON STARTED");

// Loop through node sizes
for i = 1:length(node_sizes)

    n = node_sizes(i);
    disp("Processing Network with Nodes = " + string(n));

    // Create network
    g = NL_T_LocalityConnex(n, L, dmax);

    // Show graph
    scf(1);
    clf();
    NL_G_ShowGraphN(g, 1);
    xtitle("Network Topology with " + string(n) + " Nodes");

    sleep(500);

    // Random source node
    source = NL_F_RandInt1n(length(g.node_x));

    // -------- Bellman-Ford --------
    temp_bf = zeros(1,3);

    for k = 1:3
        timer();
        [dist1, pred1] = NL_R_BellmanFord(g, source);
        temp_bf(k) = timer();
    end

    bf_time(i) = mean(temp_bf);

    // -------- Dijkstra --------
    temp_dj = zeros(1,3);

    for k = 1:3
        timer();
        [dist2, pred2] = NL_R_Dijkstra(g, source);
        temp_dj(k) = timer();
    end

    dj_time(i) = mean(temp_dj);

    // Display results
    disp("   Bellman Ford Time = " + string(bf_time(i)));
    disp("   Dijkstra Time     = " + string(dj_time(i)));
    disp("---------------------------------------");

end

disp("All Networks Created and Routed Successfully.");

// Plot comparison
scf(2);
clf();

plot(node_sizes, bf_time, '-o');
plot(node_sizes, dj_time, '-s');

legend("Bellman Ford", "Dijkstra");
xgrid();

xtitle("Routing Algorithm Time Comparison", ...
       "Number of Nodes", ...
       "Execution Time");

disp("Final Comparison Graph Generated.");
disp("TASK 1 COMPLETED SUCCESSFULLY.");
