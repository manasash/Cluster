classdef funcs
    methods(Static)
        function placeNodes(x, y, style, lwidth, edgecolor, facecolor, size)
            if style == '^'
                for i = 1:2
                    plot(x, y, style,...
                        'LineWidth', lwidth,...
                        'MarkerEdgeColor', edgecolor,...
                        'MarkerFaceColor', facecolor,...
                        'MarkerSize', size)
                    style = 'v';
                end
            else
                plot(x, y, style,...
                    'LineWidth', lwidth,...
                    'MarkerEdgeColor', edgecolor,...
                    'MarkerFaceColor', facecolor,...
                    'MarkerSize', size)
            end
        end
        
        function draw_circle1(x,y,R,c)
            % Initialise the snake
            t = 0:0.05:6.28;
            x1 = (x + R*cos(t))';
            y1 = (y + R*sin(t))';
            XS=[x1; x1(1)];
            YS=[y1; y1(1)];
            line(XS,YS,'color',c);
        end
        
        function register_nodes(blocksz,num_nodesz)
            load myvars.mat
            for i=1:blocksz
                for ji=1:num_nodesz
                    linky(1,ji)=line([bs_x X22{1,i}(ji)], [bs_y Y22{1,i}(ji)],'LineWidth', 0.25, 'LineStyle', ':', 'color', 'k');
                end
                lince{1,i}=linky;
            end
            if (1)
                for jio=1:ext_mal
                    linkyx(1,jio)=line([bs_x X10(jio,1)], [bs_y Y10(jio,1)],'LineWidth', 0.25, 'LineStyle', ':', 'color', 'k');
                end
                pause (2);
                delete(linkyx);
            end
            if(1)
                for nin=1:sn
                    delete(lince{nin});
                end
            end
            pause(2)
            tempx=cell(1,sn);
            tempy=cell(1,sn);
            for nint=1:sn
                tempx{1,nint} = cat(2,X22{1,nint},x(nint));
                tempy{1,nint} = cat(2,Y22{1,nint},y(nint));
            end
            
            for cID = 1:blocks
                if cID ~= mal_node_clstr
                    nmt_nid(1:num_nodes,1) = 1:1:num_nodes;
                    nmt_cid(1:num_nodes,1) = cID;
                    nmt_regMsg = randstr([num_nodes 5],2,'useWildCards',false,'useDigits',0);
                    for nodeID = 1:num_nodes
                        % assign node parameters
                        nmt.cluster_ID = cID;
                        nmt.node_ID = nodeID;
                        nmt.reg_Msg = nmt_regMsg(nodeID,:);
                        
                        node_parameters{cID,nodeID} = nmt; % node parameters of all nodes in the network
                        
                        nmt_c.mem_nodeIDs = nmt_nid; % node IDs of all members in the cluster
                        nmt_c.mem_cIDs = nmt_cid; % cluster IDs of all members in the cluster
                        nmt_c.reg_msgs = nmt_regMsg; %registration messages of every node in the cluster
                        nm_table = struct2table(nmt_c);
                        nm_table_n{nodeID} = nm_table;
                    end
                    nm_table_c{cID} = nm_table_n; % cluster member information table of every node in the network
                else
                    nmt_nidm(1:num_nodes+ext_mal,1) = 1:1:num_nodes+ext_mal;
                    nmt_cidm(1:num_nodes+ext_mal,1) = cID;
                    nmt_regMsgm = randstr([num_nodes+ext_mal 5],2,'useWildCards',false,'useDigits',0);
                    for nodeIDn = 1:num_nodes + ext_mal
                        % assign node parameters
                        nmtm.cluster_ID = cID;
                        nmtm.node_ID = nodeIDn;
                        nmtm.reg_Msg = nmt_regMsgm(nodeIDn,:);
                        
                        node_parameters{cID,nodeIDn} = nmtm; % node parameters of all nodes in the network
                        
                        nmt_cm.mem_nodeIDs = nmt_nidm; % node IDs of all members in the cluster
                        nmt_cm.mem_cIDs = nmt_cidm; % cluster IDs of all members in the cluster
                        nmt_cm.reg_msgs = nmt_regMsgm; %registration messages of every node in the cluster
                        nm_tablem = struct2table(nmt_cm);
                        nm_table_nm{nodeIDn} = nm_tablem;
                    end
                    nm_table_c{cID} = nm_table_nm;
                end
            end
            
            
            for val1 = 1:num_nodes
                for val = 1:ext_mal
                    temt = nm_table_c{mal_node_clstr}{val1};
                    temt{num_nodes+val, 3} = 0;
                    nm_table_c{mal_node_clstr}{val1} = temt;
                end
            end
            
            % exchange of registration messages
            linecom = cell(1,sn);
            mali = randi([1 num_nodes]);
            for commu = 1:sn
                for comm = 1:num_nodes
                    for con = 1:num_nodes-1
                        linecom{1,commu}{1,comm}(con) = line([tempx{1,commu}(comm) tempx{1,commu}(con)], [tempy{1,commu}(comm) tempy{1,commu}(con)],'LineWidth', 0.25, 'LineStyle', '-', 'color', 'g');
                    end
                end
            end
            for pntr = 1:blocks
                for pnter = 1:num_nodes
                    linx = line([x(pntr) X22{pntr}(pnter)], [y(pntr) Y22{pntr}(pnter)], 'LineWidth', 0.15, 'LineStyle', '-', 'color', 'g');
                end
                hold on;
                delete(linx);
            end
            if (1)
                for extn = 1:ext_mal
                    for coni = 1:num_nodes
                        newnodel(coni) = line([X10(extn) X22{1,mal_node_clstr}(coni)], [Y10(extn) Y22{1,mal_node_clstr}(coni)],'LineWidth', 0.15, 'LineStyle', '--', 'color', 'r');
                        hold on
                    end
                    delete(newnodel);
                end
            end
            plot(X10,Y10,'or');
            pause(2);
            hold on
            
            % plotting cluster heads
            if(1)
                plot(x,y,'mo',...
                    'LineWidth',2,...
                    'MarkerEdgeColor','k',...
                    'MarkerFaceColor',[.17 0.66 .83],...
                    'MarkerSize',7.8)
                hold on
                for i=1:sn
                    str_ch = strcat('CH', num2str(i));
                    text((x(i) + 1), y(i), str_ch);
                end
            end
            for dele = 1:sn
                for delen = 1:num_nodes
                    for delenm = 1:num_nodes-1
                        delete(linecom{dele}{delen}(delenm));
                    end
                end
            end
            pause(2);
            hold on
            
            assignin('base','mali',mali);
            assignin('base','linky',linky);
            assignin('base','lince',lince);
            assignin('base','tempx',tempx);
            assignin('base','tempy',tempy);
            assignin('base','linecom',linecom);
            assignin('base','newnodel',newnodel);
            assignin('base','newnodel',newnodel);
            assignin('base','mali',mali);
            %             assignin('base','node_parameters',node_parameters);
            %             assignin('base','nm_table_c',nm_table_c);
            evalin('base','save myvars.mat');
            load myvars.mat
        end
        
        
        
    end
end