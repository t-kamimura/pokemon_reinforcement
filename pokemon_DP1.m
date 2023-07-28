clc
clear

% 環境を定義する
states = [0, 1, 6, 11, 16, 21];     % 状態(コイキングの残りHP)の集合
actions = ['T', 'D'];               % 行動(ピカチュウの出す技)の集合
damages = [5,20];                   % 技ごとのダメージ量
accuracy = [1,0.5];                 % 技ごとの命中率
discount = 1;                       % 割引率

% 方策(技を選択する確率)を定義する
policy(1,:) = [0, 1];   % 残りHPが0のとき
policy(2,:) = [0, 1];   % 残りHPが1のとき
policy(3,:) = [0, 1];   % 残りHPが6のとき
policy(4,:) = [0, 1];   % 残りHPが11のとき
policy(5,:) = [0, 1];   % 残りHPが16のとき
policy(6,:) = [0, 1];   % 残りHPが21のとき

% 状態価値関数を定義する
value = zeros(1, length(states));    % 初期値は全て0

% 収束判定の閾値
delta = 1e-6;

% 繰り返し計算によって，状態価値関数を推定する
for i = 1:10000 % 収束するのに十分な回数を繰り返す
    value_old = value;
    for i_s = 2:length(states)  % v(s=0)=0は確定しているので，i_s=2からスタート
        v = 0;
        for i_a = 1:length(actions)
            % 技が命中する場合
            next_s = max(0, states(i_s) - damages(i_a));    % HPをマイナスにしない
            v = v + policy(i_s,i_a)*accuracy(i_a)*(reward(next_s) + discount*value(states == next_s));

            % 技を外した場合
            next_s = states(i_s);
            v = v + policy(i_s,i_a)*(1-accuracy(i_a))*(reward(next_s) + discount*value(states == next_s));
        end
        value(i_s) = v;
    end
    value
    if max(abs(value - value_old)) < delta
        disp(['i=',num2str(i),'までで収束しました'])
        break
    end
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