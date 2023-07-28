% clc
clear
close all

set(0,'defaultAxesFontSize',16);
set(0,'defaultAxesFontName', 'Times new roman');
set(0,'defaultTextFontSize',16);
set(0,'defaultTextFontName', 'Times new roman');

% 状態と行動．技のダメージ量や命中率はこの時点では定義しない
states = (0:1:21)';    % 状態(コイキングの残りHP)の集合
actions = [1,2];     % 行動(ピカチュウの出す技)の集合[たいあたり，でんじほう，ピカボルト]
discount = 1.0;        % 割引率

% 初期方策
i_action = 1;
policy = zeros(length(states),length(actions));
policy(:,i_action) = 1;

% ステップサイズパラメータ
alpha = 0.2;

% イプシロン
e = 0.2;

% 状態価値関数
q = zeros(length(states),length(actions));    % 初期値は全て0

tic
% 繰り返し計算によって，現在の方策に対して状態価値関数を推定する
num = 100;
steps = zeros(num,1);
total_rewards = zeros(num,1);
for i_q = 1:num % たくさん繰り返す

    s = max(states);   % 初期状態の残りHP

    while s > 0
        if rand() < e
            % 小さい確率eでランダムに行動を選択する
            a = randi(length(actions));
        else
            % 最大の価値を持つ行動を選択する
            [~,a] = max(q(states==s,:));
        end
        next_s = battle(s,a);
        r = reward(next_s);

        q(states==s,actions==a) = q(states==s,actions==a) + alpha*(r + discount*max(q(states==next_s,:)) - q(states==s,actions==a));

        total_rewards(i_q) = total_rewards(i_q) + discount * r;

        s = next_s;
        steps(i_q) = steps(i_q) + 1;
    end
end
for i_s = 1:length(states)
    [~,max_a] = max(q(i_s,:));
    policy(i_s,:) = 0;
    policy(i_s,max_a) = 1;  % 最大の価値を持つ行動を選択する
end
fprintf([num2str(i_q),'回の繰り返し計算にかかった時間：',num2str(toc),'秒\n'])

figure
plot(steps)
xlabel('iteration')
ylabel('step number')
title('Q learning')

figure
plot(total_rewards)
xlabel('iteration')
ylabel('total reward')
title('Q learning')

%% 得られた方策を用いて，コイキングを撃破するまでに得られた報酬の平均を計算する
num = 1000;
total_rewards = zeros(num,1);
for i_test = 1:num
    s = max(states);   % 初期状態の残りHP
    G = 0;
    while s > 0
        a = find(policy(states==s,:),1);
        next_s = battle(s,a);
        r = reward(next_s);
        G = G + discount * r;
        s = next_s;
    end
    total_rewards(i_test) = G;
end
average_reward = mean(total_rewards);
disp(['得られた方策で得られる100回の平均報酬 = ',num2str(average_reward)])

% 報酬関数を定義する
function r = reward(next_s)
    % コイキングを撃破していれば報酬を得る．そうでなければペナルティ
    if next_s == 0
        r = 10;
    else
        r = -1;
    end
end

%% ポケモンバトルの設定
% これ以降は実は不明ということになっている．実際，結果以外は他のアルゴリズムのところに明示的に関与しない
function s_new = battle(s,a)
    damages = [1, 20, 15];      % 技ごとのダメージ量
    accuracy = [1, 0.5, 0.85];  % 技ごとの命中率

    if rand() < accuracy(a) % 技が命中する場合
        s_new = max(0, s - damages(a)); % HPをマイナスにしない
    else
        s_new = s;
    end
end