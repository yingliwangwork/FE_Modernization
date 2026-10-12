
/*! 
 * FKMask.js
 * Updated: 2026-01-09
 * 目的：
 * - 分層遮蔽外掛（Input）：focus 顯示真值、blur 顯示遮蔽；不使用 type="password"
 * - 使用 jQuery valHooks，只攔截已註冊 FKMASK 的 input。
 * - 調整：外部呼叫 .val(value) 後，**一律依當前遮蔽開關**決定畫面顯示（即使元素在 focus 中）。
 * 開發者注意：
 * - 純畫面重繪請使用 writeDisplay($el, value) 或直接寫 DOM（elem.value），不要用 $el.val(...)
 *   以免 valHooks.set 把遮蔽字串誤同步到 fkmask.real。
 */
(function ($) {
  'use strict';

  /** 全域設定 */
  const config = {
    maskChar: '*',
    showFirst: 3,
    showLast: 3,
    eyeCloseClass: 'icon60',
    eyeOpenClass: 'icon61',
    defaultMask: true
  };
  /** 內部：註冊組（listKey）管理 */
  const groups = {};
  function _key(listKey) {
    return String(listKey || '_default');
  } function _group(listKey) {
    const k = _key(listKey);
    if (!groups[k]) groups[k] = { elements: [], state: (config.defaultMask ? 'masked' : 'unmasked') };
    return groups[k];
  }
  /**
   * $.FKMask.registerElement(el, listKey)
   * 目的：註冊單一元素遮蔽邏輯，加入指定註冊組（listKey）
   * 說明：不插入 ICON、不包裝 DOM
   */
  function registerElement(el, listKey) {
    const $el = (el && el.jquery) ? el : $(el);
    if (!$el || !$el.length) return;
    const tag = String($el.prop('tagName') || '').toLowerCase();
    if (tag === 'input') setupInput($el);
    _group(listKey).elements.push($el);
  }
  /**
 * $.FKMask.registerMask(container, listKey)
 */
  function registerMask(container, listKey) {
    const $c = (container && container.jquery) ? container : $(container);
    if (!$c.length) return;
    $c.find('input').each(function () {
      registerElement($(this), listKey);
    });
  }
  /**
   * 工具：產生遮蔽字串（前 N + ***** + 末 N；不分組）
   * 規則：
   * - 若 len === 2 => 強制使用 showFirst=1, showLast=0 （輸出 "a*"）
   * - 其餘若 len < (showFirst + showLast + 1) => 一律採預設 showFirst=1, showLast=1
   * - 其他維持原本 config 設定
   */
  function formatMasked(raw) {
    const s = String(raw ?? '');
    if (!s) return '';
    // 原始設定
    let nLast = parseInt(config.showLast) || 0;
    let nFirst = parseInt(config.showFirst) || 0;
    const len = s.length;
    // 特例：len=2 時，遮蔽最後一個字
    if (len === 2) {
      nFirst = 1;
      nLast = 0;
    }
    // 一般簡化規則：不足以產生中段遮蔽時，採 1,1
    else if (len < (nFirst + nLast + 1)) {
      nFirst = 1;
      nLast = 1;
    }
    // 若可視長度覆蓋整段（沒有中段可遮），沿用既定回傳原字串的行為
    if (len <= (nFirst + nLast)) return s;
    const head = (nFirst > 0) ? s.slice(0, nFirst) : '';
    const tail = (nLast > 0) ? s.slice(-nLast) : '';
    const middle = config.maskChar.repeat(Math.max(0, len - nFirst - nLast));
    return head + middle + tail;
  }
  /**
   * 工具：僅「重繪畫面」用的安全寫入（避免觸發 valHooks）
   * 說明：
   * - 這是外掛內部重繪顯示的唯一入口；不要在這裡同步 fkmask.real。
   * - 會短暫設置 data('fkmask._internal', true)，讓 valHooks.set 看見後直接放行。
   */
  function writeDisplay($el, display) {
    $el.data('fkmask._internal', true);
    try {
      const elem = $el[0];
      if (elem) elem.value = String(display ?? '');
    } finally {
      $el.removeData('fkmask._internal');
    }
  }
  /** Input：遮蔽邏輯（focus/blur，同步真值） */
  function setupInput($el) {
    if ($el.data('fkmask')) return;
    // 初始化真值、狀態、編輯旗標
    $el.data('fkmask.real', String($el[0]?.value ?? ''));
    $el.data('fkmask.state', (config.defaultMask ? 'masked' : 'unmasked'));
    $el.data('fkmask.editing', false);
    $el.data('fkmask', true);
    // 初始畫面：依狀態重繪（只重繪，不同步）
    const real = String($el.data('fkmask.real') || '');
    writeDisplay($el, ($el.data('fkmask.state') === 'masked') ? formatMasked(real) : real);
    // focus：顯真值（只重繪，不同步）
    $el.on('focus.fkmask', function () {
      $el.data('fkmask.editing', true);
      writeDisplay($el, String($el.data('fkmask.real') || ''));
    });
    // input/change：同步真值（只在編輯模式）
    $el.on('input.fkmask change.fkmask', function () {
      if ($el.data('fkmask.editing')) {
        // 直接讀 DOM 的值，避免 valHooks.get 回傳舊的 real
        const current = String($el[0]?.value ?? '');
        $el.data('fkmask.real', current);
      }
    });
    // blur：退出編輯、依狀態顯示（只重繪，不同步）
    $el.on('blur.fkmask', function () {
      // 讀畫面上的值作為最新真值
      const current = String($el[0]?.value ?? '');
      $el.data('fkmask.real', current);
      $el.data('fkmask.editing', false);
      const masked = ($el.data('fkmask.state') === 'masked');
      writeDisplay($el, masked ? formatMasked(current) : current);
    });
  }
  /** 切換：input（依狀態重繪；不改真值） */
  function setInputMasked($el, masked) {
    $el.data('fkmask.state', masked ? 'masked' : 'unmasked');
    const real = String($el.data('fkmask.real') || '');
    // 這裡維持原本的「編輯中顯真值」行為
    const isEditing = $el.is(':focus') || !!$el.data('fkmask.editing');
    const display = isEditing ? real : (masked ? formatMasked(real) : real);
    writeDisplay($el, display);
  } 
  /** 切換：整組 */
  function setGroupMasked(listKey, masked) {
    const g = _group(listKey);
    g.state = masked ? 'masked' : 'unmasked';
    g.elements.forEach(function ($el) {
      const tag = String($el.prop('tagName') || '').toLowerCase();
      if (tag === 'input') setInputMasked($el, masked);
    });
  }
  /**
   * $.FKMask.attachEye(target, listKey)
   * 把指定元素改造成眼睛按鈕（messageBtn 結構），用來切換整組遮蔽/顯示
   * 產出結構：
   * <button class="messageBtn mr0" type="button">
   *   <div id="btnEye"></div>
   *   <i class="icon51 icon50" role="button" aria-label="切換遮蔽"></i>
   * </button>
   */
  function attachEye(target, listKey) {
    const $t = (target && target.jquery) ? target : $(target);
    if (!$t || !$t.length) return;
    const g = _group(listKey);
    const isMasked = (g.state === 'masked');
    const cls = isMasked ? config.eyeCloseClass : config.eyeOpenClass;
    const innerId = $t.attr('id') || 'btnEye';
    const $btn = $('<button class="messageBtn mr0" type="button"></button>');
    const $div = $('<div></div>').attr('id', innerId);
    const $icon = $(`<i class="${cls}" role="button" aria-label="切換遮蔽"></i>`);
    $btn.append($div).append($icon);
    const toggle = function () {
      const toMasked = !(g.state === 'masked');
      setGroupMasked(listKey, toMasked);
      $icon.removeClass(config.eyeOpenClass + ' ' + config.eyeCloseClass).addClass((_group(listKey).state === 'masked') ? config.eyeCloseClass : config.eyeOpenClass);
    };
    $btn.on('click.fkmask', toggle).on('keydown.fkmask', function (e) {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        toggle();
      }
    });
    $t.replaceWith($btn);
    return $btn;
  }
  // 導出 API
  $.FKMask = { config, registerElement, registerMask, attachEye, setGroupMasked };

  /** valHooks：只攔截「已註冊 FKMASK 的 input」之 .val 行為
   * 調整重點：外部 .val(value) 後，**一律依遮蔽開關**決定畫面。
   */
  function installValHook(key) {
    $.valHooks[key] = {
      get: function (elem) {
        const $el = $(elem);
        if ($el.data('fkmask')) {
          const real = $el.data('fkmask.real');
          return (real != null) ? real : elem.value;
        } /* undefined => 原生 */
      },
      set: function (elem, value) {
        const $el = $(elem);
        if ($el.data('fkmask')) {
          if ($el.data('fkmask._internal')) {
            const val = String(value ?? '')
            elem.value = val;
            return val;
          }
          const real = String(value ?? '');
          $el.data('fkmask.real', real);
          const display = ($el.data('fkmask.state') === 'masked') ? formatMasked(real) : real;
          elem.value = display;
          return display;
        }
        /* undefined => 原生 */
      }
    };
  }
  installValHook('input');
})(jQuery);
