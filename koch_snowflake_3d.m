% Copyright (c) 2023, Yu Xiong , email:xiongyuup@163.com
% All rights reserved.
% Civil Aviation University of China (CAUC)
%
% This code is the property of Yu Xiong and is protected under copyright law.
% Redistribution and use of this code, with or without modification, are
% permitted provided that the following conditions are met:
%
% 1. The code is for non-commercial use only.
% 2. Redistributions of the code must retain the above copyright notice,
%    this list of conditions, and the following disclaimer.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
% 版权 © 2023, 熊玉
% 所有权利保留。
% 中国民航大学 (CAUC)
function koch_snowflake_3d(n, h, initial_length)
    % 绘制三维科赫雪花，n是迭代次数，h是高度，initial_length是初始边长。

    % 初始化顶点
    theta = (0:5) * pi/3;
    radius = initial_length; % 初始半径，初始边长
    vertices = [radius * cos(theta); radius * sin(theta); zeros(1, 6)];

    % 准备画图
    figure;
    hold on;
    axis equal;
    grid on;

    % 中心高度偏移
    offset_height = h / 2;

    % 计算顶点数组的总长度
    num_points_per_side = 4^n - 1; % 每边的顶点数，每次迭代边数增加4倍，减1避免重复计算端点
    total_points = 6 * (num_points_per_side + 1); % 总顶点数，+1 为了闭合每边的端点
    top_vertices = zeros(3, total_points);
    bottom_vertices = zeros(3, total_points);

    % 生成顶面和底面顶点数据
    current_index = 1;
    for i = 1:6
        p1 = vertices(:, i);
        p2 = vertices(:, mod(i, 6) + 1);
        [top_line, bottom_line] = draw_koch_side(p1, p2, n, offset_height, -offset_height);
        num_points_in_line = size(top_line, 2);
        end_index = current_index + num_points_in_line - 1;
        top_vertices(:, current_index:end_index) = top_line;
        bottom_vertices(:, current_index:end_index) = bottom_line;
        current_index = end_index + 1; % 更新起始索引
    end

    % 绘制侧面
    for i = 1:(total_points-1)
        next_index = i + 1;
        patch('Vertices', [top_vertices(:, i)'; bottom_vertices(:, i)'; bottom_vertices(:, next_index)'; top_vertices(:, next_index)'], ...
              'Faces', [1, 2, 3, 4], ...
              'FaceColor', 'cyan', 'EdgeColor', 'b');  % 侧面填充为青色
    end
    save top top_vertices
    % 绘制顶部和底部
    fill3(top_vertices(1,:), top_vertices(2,:), top_vertices(3,:), 'r');     % 填充顶部为红色
    fill3(bottom_vertices(1,:), bottom_vertices(2,:), bottom_vertices(3,:), 'b'); % 填充底部为蓝色

    % 设置视图和坐标轴限制
    view(3);  % 切换到三维视图
    axis([-1.5*radius 1.5*radius -1.5*radius 1.5*radius -offset_height offset_height]);
    xlabel('X');
    ylabel('Y');
    zlabel('Z');

    hold off;
end

function [top_line, bottom_line] = draw_koch_side(p1, p2, n, top_offset, bottom_offset)
    if n == 0
        % 基本情形，绘制直线段
        top_line = [p1, p2] + [0;0;top_offset];
        bottom_line = [p1, p2] + [0;0;bottom_offset];
    else
        % 递归分割边缘
        dp = (p2 - p1) / 3;
        p3 = p1 + dp;
        p4 = p1 + 2 * dp;
        dp_perp = [0 -1; 1 0; 0 0] * dp(1:2); % 只对x,y分量做旋转
        p5 = p1 + 1.5 * dp + dp_perp * sqrt(3) / 2; % Z坐标不变

        [top_line1, bottom_line1] = draw_koch_side(p1, p3, n-1, top_offset, bottom_offset);
        [top_line2, bottom_line2] = draw_koch_side(p3, p5, n-1, top_offset, bottom_offset);
        [top_line3, bottom_line3] = draw_koch_side(p5, p4, n-1, top_offset, bottom_offset);
        [top_line4, bottom_line4] = draw_koch_side(p4, p2, n-1, top_offset, bottom_offset);

        top_line = [top_line1(:, 1:end-1), top_line2(:, 1:end-1), top_line3(:, 1:end-1), top_line4];
        bottom_line = [bottom_line1(:, 1:end-1), bottom_line2(:, 1:end-1), bottom_line3(:, 1:end-1), bottom_line4];
    end
end
