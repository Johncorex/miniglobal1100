#ifndef FS_TOOLS_H_5F9A9742DA194628830AA1C64909AE43
#define FS_TOOLS_H_5F9A9742DA194628830AA1C64909AE43

#include <random>
#include <type_traits>
#include <fmt/core.h>

#include "position.h"
#include "const.h"
#include "enums.h"

void printXMLError(const std::string& where, const std::string& fileName, const pugi::xml_parse_result& result);

std::string transformToSHA1(const std::string& input);
std::string generateToken(const std::string& key, uint32_t ticks);

void replaceString(std::string& str, const std::string& sought, const std::string& replacement);
void trim_right(std::string& source, char t);
void trim_left(std::string& source, char t);
void toLowerCaseString(std::string& source);
std::string asLowerCaseString(std::string source);
std::string asUpperCaseString(std::string source);

using StringVector = std::vector<std::string>;
using IntegerVector = std::vector<int32_t>;

StringVector explodeString(const std::string& inString, const std::string& separator, int32_t limit = -1);
IntegerVector vectorAtoi(const StringVector& stringVector);
constexpr bool hasBitSet(uint32_t flag, uint32_t flags) {
	return (flags & flag) != 0;
}

std::mt19937& getRandomGenerator();
int32_t uniform_random(int32_t minNumber, int32_t maxNumber);
int32_t normal_random(int32_t minNumber, int32_t maxNumber);
bool boolean_random(double probability = 0.5);

Direction getDirection(const std::string& string);
Position getNextPosition(Direction direction, Position pos);
Direction getDirectionTo(const Position& from, const Position& to);

std::string getFirstLine(const std::string& str);

std::string formatDate(time_t time);
std::string formatDateShort(time_t time);
std::string convertIPToString(uint32_t ip);

void trimString(std::string& str);

MagicEffectClasses getMagicEffect(const std::string& strValue);
ShootType_t getShootType(const std::string& strValue);
Ammo_t getAmmoType(const std::string& strValue);
WeaponAction_t getWeaponAction(const std::string& strValue);
Skulls_t getSkullType(const std::string& strValue);
std::string getCombatName(CombatType_t combatType);

std::string getSpecialSkillName(uint8_t skillid);
std::string getSkillName(uint8_t skillid);

uint32_t adlerChecksum(const uint8_t* data, size_t length);

std::string ucfirst(std::string str);
std::string ucwords(std::string str);
bool booleanString(const std::string& str);

std::string getWeaponName(WeaponType_t weaponType);

size_t combatTypeToIndex(CombatType_t combatType);
CombatType_t indexToCombatType(size_t v);

uint8_t serverFluidToClient(uint8_t serverFluid);
uint8_t clientFluidToServer(uint8_t clientFluid);

itemAttrTypes stringToItemAttribute(const std::string& str);

const char* getReturnMessage(ReturnValue value);

int64_t OTSYS_TIME();

SpellGroup_t stringToSpellGroup(const std::string& value);

template<typename T>
std::vector<T> selectRandom(std::vector<T> from, size_t k) {
	std::shuffle(begin(from), std::end(from), getRandomGenerator());
	from.resize(std::min<size_t>(k, from.size()));
	std::sort(std::begin(from), std::end(from));
	return from;
}
template<typename T, typename... Args>
std::vector<T> selectRandom(std::vector<T> from, size_t k, const std::vector<T>& elim, Args&&... args) {
	std::vector<T> wh;
	auto it2 = std::begin(elim);
	for (auto it1 = std::begin(from); it1 != std::end(from); it1++) {
		while (it2 != std::end(elim) && *it2 < *it1) it2++;
		if (it2 == std::end(elim) || *it2 > *it1) {
			wh.emplace_back(std::move(*it1));
		}
	}
	return selectRandom(std::move(wh), k, std::forward<Args>(args)...);
}
template < typename E >
auto format_as(E e) {
	return fmt::underlying(e);
}

#endif