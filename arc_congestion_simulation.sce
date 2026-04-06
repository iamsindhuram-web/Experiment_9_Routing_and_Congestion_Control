clc;
clear;
funcprot(0);

// ---------------- ARC CONGESTION CONTROL FUNCTION ----------------
function duration = run_ARC_Simulation(adj, capacity)

    n = size(adj, 1);
    flow = (rand(n, n) .* double(adj)) * 1.8;
    alpha = 0.15;
    max_iters = 350;

    timer();

    for iter = 1:max_iters
        congested = (flow > capacity) & (adj == 1);
        if ~or(congested) then
            break;
        end
        flow(congested) = flow(congested) - alpha * (flow(congested) - capacity);
    end

    duration = timer();
endfunction


// ---------------- TOPOLOGY VISUALIZATION FUNCTION ----------------
function visualize_topology(N, win_id, title_str)

    scf(win_id); clf();

    L = 1000;
    x = rand(1, N) * 850;
    y = rand(1, N) * 750;

    plot2d([], [], 0, "011", " ", [0, 0, L, L]);
    set(gca(), "grid", [1, 1] * 1);
    set(gca(), "sub_ticks", [4, 4]);

    adj_vis = (rand(N, N) < (1.6/N));

    for i = 1:N
        for j = i+1:N
            if adj_vis(i,j) == 1 then
                plot([x(i), x(j)], [y(i), y(j)], 'k-', 'LineWidth', 0.5);
            end
        end
    end

    plot(x, y, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'w');

    for i = 1:min(N, 35)
        xstring(x(i)+10, y(i)+10, string(i));
        e = gce();
        e.font_size = 1;
    end

    xtitle(title_str);
endfunction


// ---------------- TASK 1: 200 & 300 NODE SIMULATION ----------------
disp("--- TASK 1: 200 & 300 Node Simulation ---");

init_sizes = [200, 300];
init_results = [];

for i = 1:length(init_sizes)

    n = init_sizes(i);

    visualize_topology(n, i-1, "Network Topology: " + string(n) + " Nodes");

    adj_temp = (rand(n, n) < 0.04);

    init_results(i) = run_ARC_Simulation(double(adj_temp), 0.7);

    disp("Nodes: " + string(n) + " | Duration: " + string(init_results(i)));

end


// Plot for Task 1
scf(2); clf();
bar(init_sizes, init_results);

xtitle("ARC Congestion Duration: 200 vs 300 Nodes",
       "Node Count",
       "Time (s)");


// ---------------- TASK 2: 500 NODE REDUCTION ----------------
disp("--- TASK 2: 500 Node Reduction & 5 Methods ---");

methods = ["Random", "Grid", "Star", "Ring", "SmallWorld"];
node_steps = [500, 400, 300, 200, 100];

final_metrics = zeros(5, 5);

// Heatmap start window
heatmap_start_win = 10;

for m = 1:5

    disp("Processing Method: " + methods(m));

    for s = 1:5

        n = node_steps(s);
        adj = zeros(n, n);

        select m

        case 1 then
            adj = (rand(n, n) < 0.01);

        case 2 then
            sq = int(sqrt(n));
            for k = 1:n-1
                if modulo(k, sq) <> 0 then
                    adj(k, k+1) = 1;
                end
                if k + sq <= n then
                    adj(k, k+sq) = 1;
                end
            end

        case 3 then
            adj(1, 2:n) = 1;
            adj(2:n, 1) = 1;

        case 4 then
            for k = 1:n-1
                adj(k, k+1) = 1;
            end
            adj(n,1) = 1;

        case 5 then
            for k = 1:n-1
                adj(k, k+1) = 1;
            end
            adj = adj | (rand(n,n) < 0.002);

        end

        final_metrics(m, s) = run_ARC_Simulation(double(adj), 0.7);


        // -------- HEATMAP FOR RANDOM METHOD --------
        if m == 1 then

            scf(heatmap_start_win + (s-1)); clf();

            f = gcf();
            f.color_map = hotcolormap(64);

            map_res = n / 10;
            congestion_data = rand(map_res, map_res) * 80;

            grayplot(1:map_res, 1:map_res, congestion_data);

            xtitle("Congestion Map: " + string(n) + " Nodes",
                   "X-Clusters",
                   "Y-Clusters");
        end



  end
end

scf(5); clf();
plot(node_steps, final_metrics', '-o', 'LineWidth', 2);
legend(methods);
xgrid();
xtitle("ARC Duration vs Node Reduction (5 Methods)",
   "Number of Nodes",
 "Time (s)");
disp("--- TASK 2 COMPLETED SUCCESSFULLY ---");
