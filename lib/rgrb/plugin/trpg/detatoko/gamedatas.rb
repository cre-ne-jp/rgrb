# vim: fileencoding=utf-8

module RGRB
  module Plugin
    module Trpg
      module Detatoko
        class Generator
          # 烙印
          # :v 体力
          # :m 気力
          STIGMAS = {
            v: %w(痛手 流血 衰弱 苦悶 衝撃 疲労 怒号 負傷 軽傷 nil),
            m: %w(絶望 号泣 後悔 恐怖 葛藤 憎悪 呆然 迷い 悪夢 nil)
          }

          # バッドエンド
          BADENDS = {
            v: %w(死亡 命乞 忘却 悲劇 暴走 転落 虜囚 逃走 重症 気絶 なし),
            m: %w(自害 堕落 隷属 裏切 暴走 呪い 虜囚 逃走 放心 気絶 なし)
          }

          # 出目から対応するラスボス立場を決定するための表
          GROUNDS = {
            normal: %w(恐怖 破壊 封印 滅亡 侵略 暴君 陰謀 独裁 崇拝 犠牲 人望),
            dark: %w(外的存在 下衆 悪の同輩 悪の先達 有象無象 討伐者 新たな力 邪魔者 反逆者 希望 世界法則)
          }

          # スタンス表を定義する
          # 敵視～不明：基本
          # 関係・意思：ワールドツアー
          STANCES = {
            '敵視' => %w(邪魔 好敵手 標的 使命 異世界召喚 討伐者),
            '宿命' => %w(救済 神託 あの人は今 風来坊 自己投影 嵐の予兆),
            '憎悪' => %w(暗い目 悪を憎む 劣等感 怨念 裏切り 復讐),
            '雲上' => %w(怯え 小市民 懊悩 嘆願 世捨て人 誰それ?),
            '従属' => %w(隷従 呪縛 勘違い 弱肉強食 居場所 心酔),
            '不明' => %w(野心の炎 大いなる御方 戯れ 好奇心 天秤 超越),
            '関係' => %w(知りたい この手に 好敵手 追求 誰がために 負の因縁),
            '意思' => %w(あの舞台に 誇り高き義務 栄光の階 引退者 恐怖の主 猫か虎か)
          }

          # クラス表
          CLASSES = {
            '勇者' => 1,
            '魔王' => 2,
            'お姫様' => 3,
            'ドラゴン' => 4,
            '戦士' => 5,
            '魔法使い' => 6,
            '神聖' => 7,
            '暗黒' => 8,
            'マスコット' => 9,
            'モンスター' => 10,
            '謎' => 11,
            'ザコ' => 12,
            # フロンティア
            'メカ' => 13,
            '商人' => 14,
            '占い師' => 15,
            # ダークネス
            'ニンジャ' => 0,
            '貴族' => 3,
            '死霊' => 8,
            # ワールドツアー
            '探偵' => 1,
            'サムライ' => 5,
            'シャーマン' => 7,
            'アイドル' => 9
          }

          # ポジション
          POSITIONS = {
            # フロンティア
            pc: %w(
              冒険者 凡人 夢追い 神話の住人 負け犬 守護者 悪党 カリスマ 修羅
              遊び人 従者 正体不明 迷い子 生ける伝説 罪人 傷追人 型破り 裏の住人
            ),
            # フロンティア・ダークネス・ワールドツアー
            # 敵NPCポジション
            npc: %w(
              裏切者 帝王 悪の化身 黒幕 災厄 侵略者
              妨害者 影 愚物 慈母 世界 いわくつき
              対立者 標的 執行者 導き手
            ),
            # ダークネス
            # 悪のポジション
            dark: %w(
              悪の華 堕落者 幹部 トリックスター 無能 支配者
              狂的天才 必要悪 外道 野獣 死の使い 破滅の因子
            )
          }

          # 【好きなもの・趣味】／【苦手なもの・弱点】表
          LIKE_THINGS = [
            %w(食 甘い食べ物、お菓子 辛い食べ物 特定の食べ物 お茶 酒),
            %w(家事・料理 掃除、整理・整頓、収納 手芸・裁縫 入浴・風呂・温泉 化粧・ファッション 買い物・浪費／倹約・貯金),
            %w(異性 同性 魚介類・触手生物 虫・爬虫類 キノコ・菌類 特定の生物),
            %w(幽霊・アンデッド、怪談・ホラー・オカルト 草木・花・植物 宝石・鉱物 星・天文 ぬいぐるみ・人形・かわいいもの／フィギュア・模型 占い・ジンクス),
            %w(演劇・舞踊・芸能・パフォーマンス 鍛錬・運動・筋肉トレーニング、座禅・瞑想 スポーツ 乗り物 水・水泳 特定の環境),
            %w(読書・文芸 美術品・絵画 歌・音楽・楽器演奏 施策・詩吟・ポエム／クイズ・なぞなぞ・パズル ギャンブル・賭け事 ゲーム),
            %w(暗い場所 せまい場所 高い場所 広い場所 寒さ 暑さ)
          ]

          # チャート表
          # でたとこワールドツアー
          CHARTS = {
            # ラスボスチャート
            lastboss: %w(
              【侵略】暗黒魔王
              【陰謀】謎の賢者
              【暴君】魔界番長
              【破壊】エレメンタル
              【封印】ミノタウロス
              【侵略】オーク王
              【暴君】火龍
              【陰謀】サキュバス
              【滅亡】暗黒魔道士
              【恐怖】黒騎士
              【恐怖】人狼
              【独裁】吸血鬼
              【陰謀】暗殺者
              【犠牲】堕ちた英雄
              【封印】邪神
              【独裁】ニセモノ
              【陰謀】切り裂き魔
              【恐怖】鬼
              【人望】聖騎士
              【崇拝】堕天使
              【独裁】人気者
              【破壊】大嵐
              【封印】大いなる負債
              【暴君】聖王女
              【犠牲】クラーケン
              【犠牲】ミノタウロス
              【犠牲】火龍
              【恐怖】霧の中の怪物
              【崇拝】吸血鬼
              【恐怖】狂気の怪物
              【滅亡】暗黒の塔
              【封印】墜ちた城
              【恐怖】大迷宮
              【人望】人気者
              【崇拝】大舞台
              【人望】ライバル
            ),
            # クエストチャート
            quest: %w(
              噴煙を上げる灼熱の火山を目指して長い旅をする。
              モンスターのうろつく巨大な迷宮を探索する。
              謎めいた古代遺跡の秘密を調査する。
              うち捨てられて廃墟となった街を訪れる。
              魔力に満ちた原始の樹海を行く。何が飛び出してくるかわからない。
              魔法使いたちの集う都を訪ねる。
              複雑に入り組んだ下水道を通り抜け、目的地を目指す。
              危険な遠洋への航海に繰り返す。
              「地獄」と呼ばれる場所で冒険する。
              世界中を巡る。
              あらゆる悪徳の蔓延る邪悪の街に潜り込む。
              難攻不落と知られる敵の城塞に攻め入る。
              拠点を守り、巨大な敵と激突する。
              大軍勢を相手取って戦い、包囲網を打ち破る。
              ラスボスの放った強力な刺客につけ狙われる。
              脱出不可能と謳われる大監獄から脱走する。
              無実の罪を着せられ、守るべき人々から追われる身となる。
              蛮族の戦士と力比べをして、実力を認めさせる。
              思わぬ裏切りにあい窮地に陥る。
              かつての仲間と対決する。
              行方知れずの伝説の勇者を探し出す。
              わからず屋の王侯貴族や議員とやりあう。
              神や精霊の力を借りるため、試練に挑む。
              異世界の存在と接触する。
              人々の希望となり、民衆を導く。
              かつての自分を超えなければならない。
              恐ろしい病が流行する。原因を突き止めねば。
              かけられた呪いを解くために奔走する。
              伝説のアイテムを手に入れるため探索の旅に出る。
              古代の書物や碑文を読み解き、謎を解き明かす。
              囚われの姫や仲間を救出する。
              ラスボスの配下から秘密を聞き出す。
              敵の敵を味方につける。
              封印された古の存在を揺り起こす。
              開かずの扉を開く。
              国を挙げて大規模な儀式を執り行う。
            )
          }
        end
      end
    end
  end
end
