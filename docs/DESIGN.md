# 设计记录

## 目标国家

| 中文 | 英文 | tag | 文化 |
|---|---|---|---|
| 法拉内安 | Farraneán | `B60` | `farrani_half_elf` |
| 阿德尼卡 | Adenica | `B58` | escanni 组 |
| 卡斯塔诺尔 | Castanor | `B32` | `castanorian` |
| 刀锋边区 | Blademarches | `B33` | escanni 组 |
| 马尔霍德 | Marrhold | `B36` | `marrodic` |

（"东坎诺"= Escann。以上 tag 取自 PublicFork `localisation/anb_countries_l_english.yml`。）

## 已核实的技术事实

### 八旗

- `common/government_reforms/06_government_reforms_common.txt` → `eight_banners_reform`
  - `custom_attributes = { eight_banners_buff = yes }` ← 引擎开关
  - `modifiers = { amount_of_banners = 0.25 }`
  - `potential` 里的 `primary_culture = manchu` **只是解锁条件**，可替换
- 兵种：`common/units/manchu_banner.txt`（骑兵）、`han_banner.txt`（步兵）
- `defines.lua`：`BANNER_USES_CONSTRUCTION = 0`、`BANNER_STARTING_STRENGTH`、`BANNER_AGE_MULTIPLIER`

### 翼骑兵 / mythical cavalry

- PublicFork `common/event_modifiers/anb_mythical_cavalry_modifiers.txt`
  - 每个坐骑是 `mythical_cavalry_<name>`，必须带 `is_hussars_modifier = yes`
  - `mythical_cavalry_enabler` 提供 `can_recruit_hussars = yes`
- `common/static_modifiers/00_static_modifiers.txt`：`hussars_regiment = { local_amount_of_hussars = 0.01 }` → 100 发展度 1 队
- `amount_of_hussars` 为额外固定队数（原版波兰贵族特权给 6）

## 待定

1. 骑士上限：按发展度 / 固定队数 / 混合？
2. 四国特权挂哪个阶层（贵族？冒险团？自动适配？）
3. Marrhold 是否并入同一个「王国骑士」体系，还是独立改革？
