% clc
clear

% 状態と行動を定義する．技のダメージ量や命中率はこの時点では定義しない
states = (0:1:21)';                 % 状態(コイキングの残りHP)の集合
actions = [1,2,3];                  % 行動(ピカチュウの出す技)の集合[たいあたり，でんじほう，ピカボルト]
discount = 1.0;                     % 割引率

% 初期方策を定義する
policy = zeros(length(states),length(actions));
policy(:,1) = 1;

% 状態価値関数を定義する
q = zeros(length(states),length(actions));    % 初期値は全て0

% メモリを節約して平均値を求めるための個数カウント
cnt = zeros(length(states),length(actions));

tic
% 繰り返し計算によって，現在の方策に対して状態価値関数を推定する
for i_q = 1:1e5 % たくさん繰り返す

    s0 = round(rand()*(max(states)-1))+1;   % 初期状態の残りHPをランダムに決定する
    a0 = round(rand()*(max(actions)-1))+1;  % 初期行動をランダムに決定する
    [sset,aset,rset] = episode(s0,a0, policy,states); % 1回の戦闘が終了するまで実行する

    G = 0;
    for i_s = length(sset):-1:1
        s = sset(i_s);
        a = aset(i_s);
        G = G + discount * rset(i_s);
        cnt(states==s,actions==a) = cnt(states==s,actions==a) + 1;
        q(states==s,actions==a) = (q(states==s,actions==a)*(cnt(states==s,actions==a)-1) + G)/cnt(states==s,actions==a); % 平均値を求める
        [max_q, max_a] = max(q(states==s,:));
        policy(states==s,:) = zeros(1,length(actions));
        policy(states==s,max_a) = 1;
    end
end
fprintf([num2str(i_q),'回の繰り返し計算にかかった時間：',num2str(toc),'秒\n'])

%% 得られた方策を用いて，コイキングを撃破するまでに得られた報酬の平均を計算する
num = 100;
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

% エピソード(1回の戦闘が終了するまで)を定義する
function [sset,aset,rset] = episode(s0,a0,policy,states)
    s = s0;     % 戦闘開始時のコイキングの残りHP
    a = a0;     % 戦闘開始時のピカチュウの技
    % はじめの1ターンは，引数で与えられた状態と行動を使う
    next_s = battle(s,a);
    r = reward(next_s);
    sset = s;
    aset = a;
    rset = r;
    s = next_s;
    % その後は，現在の方策に従って行動を選択する
    while s > 0
        a = find(policy(states==s,:),1);
        next_s = battle(s,a);
        r = reward(next_s);
        sset = [sset, s];
        aset = [aset, a];
        rset = [rset, r];
        s = next_s;
    end
end

% 1ターンの戦闘を定義する
function s_new = battle(s,a)
    damages = [5, 20, 15];      % 技ごとのダメージ量
    accuracy = [1, 0.5, 0.85];  % 技ごとの命中率

    if rand() < accuracy(a) % 技が命中する場合
        s_new = max(0, s - damages(a)); % HPをマイナスにしない
    else
        s_new = s;
    end
end