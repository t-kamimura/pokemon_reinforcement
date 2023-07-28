% clc
clear

set(0,'defaultAxesFontSize',16);
set(0,'defaultAxesFontName', 'Times new roman');
set(0,'defaultTextFontSize',16);
set(0,'defaultTextFontName', 'Times new roman');

% 状態と行動を定義する．技のダメージ量や命中率はこの時点では定義しない．
states = (0:1:21)';                 % 状態(コイキングの残りHP)の集合
actions = ['T', 'D', 'P'];          % 行動(ピカチュウの出す技)の集合[たいあたり，でんじほう，ピカボルト]
discount = 1.0;                     % 割引率

% 方策を定義する．
policy = 3;

% 状態価値関数を定義する
value = zeros(length(states),1);    % 初期値は全て0

% 平均値を求めるためにデータを貯めておく箱
for i_s = 1:length(states)
    R(i_s).G = [];
end

% 状態価値関数の解析解
value_true(:, 1) = [0; 10; 10; 10; 10; 10; 9; 9; 9; 9; 9; 8; 8; 8; 8; 8; 7; 7; 7; 7; 7; 6];
value_true(:, 2) = [0; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 7];
error = zeros(1e5, 1);

tic
% 繰り返し計算によって，現在の方策に対して状態価値関数を推定する
for i_v = 1:1e5 % たくさん繰り返す

    s0 = round(rand()*max(states)); % 初期状態の残りHPをランダムに決定する
    [sset,rset] = episode(s0,policy); % 1回の戦闘が終了するまで実行する

    G = 0;
    for i_s = length(sset):-1:1
        s = sset(i_s);
        G = G + discount * rset(i_s);
        R(states==s).G = [R(states==s).G;G];
        value(states==s) = mean([R(states==s).G]);
    end

    if discount == 1 && policy < 3 % この場合は解析解を求めているので，誤差を計算する
        error(i_v) = norm(value - value_true(:, policy));
    end

end
toc

if discount == 1 && policy < 3
    figure
    plot(error)
    xlabel('episode')
    ylabel('error')
    title('Result of MC')
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

%% ポケモンバトルの設定
% これ以降は実は不明ということになっている．実際，結果以外は他のアルゴリズムのところに明示的に関与しない

% 1ターンの戦闘を定義する
function s_new = battle(s,a)
    damages = [5, 20, 10];      % 技ごとのダメージ量
    accuracy = [1, 0.5, 0.85];  % 技ごとの命中率

    if rand < accuracy(a) % 技が命中する場合
        s_new = max(0, s - damages(a)); % HPをマイナスにしない
    else
        s_new = s;
    end
end

% エピソード(1回の戦闘が終了するまで)を定義する
function [sset,rset] = episode(s0,policy)
    s = s0;     % 戦闘開始時のコイキングの残りHP
    sset = [];
    rset = [];
    while s > 0
        a = policy;
        next_s = battle(s,a);
        r = reward(next_s);
        sset = [sset, s];
        rset = [rset, r];
        s = next_s;
    end
end