clc
clear

% 環境を定義する
states = [0, 1, 6, 11, 16, 21];     % 状態(コイキングの残りHP)の集合
actions = ['T', 'D'];               % 行動(ピカチュウの出す技)の集合
damages = [5,20];                   % 技ごとのダメージ量
accuracy = [1,0.5];                 % 技ごとの命中率
discount = 0.9;                       % 割引率

% 初期方策(技を選択する確率)を定義する
policy(1,:) = [1, 0];   % 残りHPが0のとき
policy(2,:) = [1, 0];   % 残りHPが1のとき
policy(3,:) = [1, 0];   % 残りHPが6のとき
policy(4,:) = [1, 0];   % 残りHPが11のとき
policy(5,:) = [1, 0];   % 残りHPが16のとき
policy(6,:) = [1, 0];   % 残りHPが21のとき

% 状態価値関数を定義する
value = zeros(1, length(states));    % 初期値は全て0

% 収束判定の閾値
delta = 1e-6;

tic
for i_q = 1:10000
    % まず，繰り返し計算によって，現在の方策に対して状態価値関数を推定する
    for i_v = 1:10000 % 収束するのに十分な回数を繰り返す
        value_old = value;
        for i_s = 2:length(states)  % v(s=0)=0は確定しているので，i_s=2からスタート
            v = 0;
            for i_a = 1:length(actions)
                % 技が命中する場合
                next_s = max(0, states(i_s) - damages(i_a));    % HPをマイナスにしない
                v = policy(i_s,i_a)*accuracy(i_a)*(reward(next_s) + discount*value(states == next_s));

                % 技を外した場合
                next_s = states(i_s);
                v = v + policy(i_s,i_a)*(1-accuracy(i_a))*(reward(next_s) + discount*value(states == next_s));
            end
            value(i_s) = v;
        end
        if max(abs(value - value_old)) < delta
            break
        end
        pause(0.01)
    end

    % 次に，状態価値関数を用いて，方策を改善する
    policy_old = policy;
    for i_s = 2:length(states)
        % 状態価値関数を用いて，各行動の価値を計算する
        q = zeros(1, length(actions));
        for i_a = 1:length(actions)
            % 技が命中する場合
            next_s = max(0, states(i_s) - damages(i_a));    % HPをマイナスにしない
            q(i_a) = accuracy(i_a)*(reward(next_s) + discount*value(states == next_s));

            % 技を外した場合
            next_s = states(i_s);
            q(i_a) = q(i_a) + (1-accuracy(i_a))*(reward(next_s) + discount*value(states == next_s));
        end

        % 各行動の価値を用いて，方策を改善する
        [max_v, max_a] = max(q);
        policy(i_s,:) = 0;
        policy(i_s,max_a) = 1;  % 最大の価値を持つ行動を選択する
    end
    if max(abs(policy - policy_old)) < delta
        break
    end
    pause(0.01)
end
toc

disp('得られた最適方策 [Tを選択する確率,Dを選択する確率] は')
for i_s = 2:length(states)
    fprintf(['s = ', num2str(states(i_s)), '\t [', num2str(policy(i_s,1)),', ', num2str(policy(i_s,2)),']\n'])
end

% 報酬関数を定義する
function r = reward(next_s)
    % コイキングを撃破していれば報酬を得る．そうでなければペナルティ
    if next_s == 0
        r = 10;
    else
        r = -1;
    end
end