# 音声ファイル置き場

スタンプラリーで使う効果音ファイルは、この `sounds` フォルダーに置いてください。

現在の `index.html` の初期設定では、次のファイルを参照します。

- `Party_Popper01-2(Reverb).mp3`: 紙吹雪の破裂音
- `Applause03-5(Far-Mid).mp3`: 紙吹雪がちらついているときの拍手
- `ooatari1.mp3`: コンプリート時の音楽

通常のスタンプ獲得時は、破裂音のあと少し遅れて拍手が鳴ります。
コンプリート時は、コンプリート演出の開始と同時に音楽が鳴ります。

別のファイル名にしたい場合は、`index.html` 上部の `CONFIG.sound` にある `stampFile` / `applauseFile` / `completeFile` を変更してください。
ブラウザで扱いやすい形式は `.mp3`, `.wav`, `.m4a`, `.ogg` です。