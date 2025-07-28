class_name ArmorClass
extends Resource

#@export_group("Damage Multipliers", "damage_mul_")
@export_range(0.0, 4.0, 0.01, "or_greater") var generic : float = 1.0
@export_range(0.0, 4.0, 0.01, "or_greater") var explosion : float = 1.0
@export_range(0.0, 4.0, 0.01, "or_greater") var fire : float = 1.0
@export_range(0.0, 4.0, 0.01, "or_greater") var toxic : float = 1.0
@export_range(0.0, 4.0, 0.01, "or_greater") var electric : float = 1.0
@export_range(0.0, 4.0, 0.01, "or_greater") var impact : float = 1.0


## [enum Status.DamageType]-specific damage multipliers.
var damage_multipliers: Dictionary[Status.DamageType, float]:# = {
	get:
		return {
				Status.DamageType.GENERIC: generic,
				Status.DamageType.EXPLOSION: explosion,
				Status.DamageType.FIRE: fire,
				Status.DamageType.TOXIC: toxic,
				Status.DamageType.ELECTRIC: electric,
				Status.DamageType.IMPACT: impact,
		}
	set(to):
		for type: Status.DamageType in to:
			match type:
				Status.DamageType.GENERIC:
					generic = to[type]
				Status.DamageType.EXPLOSION:
					explosion = to[type]
				Status.DamageType.FIRE:
					fire = to[type]
				Status.DamageType.TOXIC:
					toxic = to[type]
				Status.DamageType.ELECTRIC:
					electric = to[type]
				Status.DamageType.IMPACT:
					impact = to[type]
