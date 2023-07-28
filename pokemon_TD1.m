% clc
clear
close all

set(0,'defaultAxesFontSize',16);
set(0,'defaultAxesFontName', 'Times new roman');
set(0,'defaultTextFontSize',16);
set(0,'defaultTextFontName', 'Times new roman');

% 状態と行動．技のダメージ量や命中率はこの時点では定義しない
states = (0:1:21)';                 % 状態(コイキングの残りHP)の集合
actions = [1,2,3];                  % 行動(ピカチュウの出す技)の集合[たいあたり，でんじほう，ピカボルト]
discount = 1.0;                     % 割引率

% 初期方策
i_action = 2;
policy = zeros(length(states),length(actions));
policy(:,i_action) = 1;

% ステップサイズパラメータ
alpha = 0.1;

% 状態価値関数
v = zeros(length(states),1);    % 初期値は全て0

% 状態価値関数の解析解
v_true(:, 1) = [0; 10; 10; 10; 10; 10; 9; 9; 9; 9; 9; 8; 8; 8; 8; 8; 7; 7; 7; 7; 7; 6];
v_true(:, 2) = [0;  9;  9;  9;  9;  9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 7];
error = zeros(1e5, 1);

tic
% 繰り返し計算によって，現在の方策に対して状態価値関数を推定する
for i_v = 1:1e5 % たくさん繰り返す

    s = round(rand()*(max(states)-1))+1;   % 初期状態の残りHPをランダムに決定する

    while s > 0
        a = find(policy(states==s,:),1);
        next_s = battle(s,a);
        r = reward(next_s);
        v(states==s) = v(states==s) + alpha*(r + discount*v(states==next_s) - v(states==s));
        s = next_s;
    end

    if discount == 1 && i_action < 3 % この場合は解析解を求めているので，誤差を計算する
        error(i_v) = norm(v - v_true(:, i_action));
    end
end
toc

if discount == 1 && i_action < 3
    figure
    semilogy(error)
    xlabel('episode')
    ylabel('error')
    title('Result of TD(0)')
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
function s_new = battle(s,a)
    damages = [5, 20, 15];      % 技ごとのダメージ量
    accuracy = [1, 0.5, 0.85];  % 技ごとの命中率

    if rand() < accuracy(a) % 技が命中する場合
        s_new = max(0, s - damages(a)); % HPをマイナスにしない
    else
        s_new = s;
    end
end