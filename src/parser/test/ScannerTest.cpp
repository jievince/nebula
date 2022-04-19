/* Copyright (c) 2018 vesoft inc. All rights reserved.
 *
 * This source code is licensed under Apache 2.0 License.
 */

#include <gtest/gtest.h>

#include <sstream>
#include <utility>
#include <vector>

#include "common/base/Base.h"
#include "parser/GraphParser.hpp"
#include "parser/GraphScanner.h"

namespace nebula {

#define CHECK_SEMANTIC_TYPE(STR, TOK)          \
  {                                            \
    auto result = checkSemanticType(STR, TOK); \
    ASSERT_TRUE(result.ok()) << result;        \
    consumeZero();                             \
  }

#define CHECK_SEMANTIC_VALUE(STR, TOK, VAL)          \
  {                                                  \
    auto result = checkSemanticValue(STR, TOK, VAL); \
    ASSERT_TRUE(result.ok()) << result;              \
    consumeZero();                                   \
  }

#define CHECK_LEXICAL_ERROR(STR, MSG)          \
  {                                            \
    auto result = checkLexicalError(STR, MSG); \
    ASSERT_TRUE(result.ok()) << result;        \
  }

#define CHECK_SEMANTIC_TYPES(STR, TOKS)          \
  {                                              \
    auto result = checkSemanticTypes(STR, TOKS); \
    ASSERT_TRUE(result.ok()) << result;          \
  }

class ScannerTest : public ::testing::Test {
 public:
  using semantic_type = nebula::GraphParser::semantic_type;
  using Token = nebula::GraphParser::token;
  using TokenType = nebula::GraphParser::token::token_kind_type;
  void SetUp() override {
    auto input = [this](char* buf, int maxSize) {
      int left = stream_.size() - copied_;
      if (left == 0) {
        return 0;
      }
      int n = left < maxSize ? left : maxSize;
      ::memcpy(buf, &stream_[copied_], n);
      copied_ += n;
      return n;
    };
    scanner_.setReadBuffer(input);
    scanner_.setDebug(true);
  }
  void TearDown() override {}

 public:
  Status checkSemanticType(const std::string& text, TokenType token) {
    stream_ += text;
    stream_ += " ZERO ";
    auto actual = scanner_.yylex(&yylval_, &yyloc_);
    if (actual != token) {
      std::ostringstream ss;
      ss << "Token not match for `" << text << "', expected: " << static_cast<TokenType>(token)
         << ", actual: " << static_cast<TokenType>(actual);
      return Status::Error(ss.str());
    }
    return Status::OK();
  }

  Status checkSemanticTypes(const std::string& text, const std::vector<TokenType>& expected) {
    stream_ += text;
    size_t i = 0;
    int token = 0;
    std::vector<TokenType> actual;
    do {
      token = scanner_.yylex(&yylval_, &yyloc_);
      actual.push_back(static_cast<TokenType>(token));
      ++i;
    } while (token != 0);
    if (expected != actual) {
      std::ostringstream ss;
      ss << "Tokens not match for `" << text << "', \nexpected: " << folly::join(",", expected)
         << ", \nactual: " << folly::join(",", actual);
      return Status::Error(ss.str());
    }
    return Status::OK();
  }

  Status checkSemanticValue(const std::string& text, TokenType token, const std::string& expected) {
    checkSemanticType(text, token);
    auto actual = yylval_.as<std::string>();
    if (expected != actual) {
      std::ostringstream ss;
      ss << "Semantic value not match, "
         << "expected: " << expected << ", actual: " << actual;
      return Status::Error(ss.str());
    }
    return Status::OK();
  }

  template <typename T>
  std::enable_if_t<std::is_integral<T>::value, Status> checkSemanticValue(const std::string& text,
                                                                          TokenType token,
                                                                          T expected) {
    checkSemanticType(text, token);
    auto actual = yylval_.as<T>();
    if (expected != actual) {
      std::ostringstream ss;
      ss << "Semantic value not match, "
         << "expected: " << expected << ", actual: " << actual;
      return Status::Error(ss.str());
    }
    return Status::OK();
  }

  template <typename T>
  std::enable_if_t<std::is_floating_point<T>::value, Status> checkSemanticValue(
      const std::string& text, TokenType token, T expected) {
    checkSemanticType(text, token);
    auto actual = yylval_.as<double>();
    if (expected != actual) {
      std::ostringstream ss;
      ss << "Semantic value not match, "
         << "expected: " << expected << ", actual: " << actual;
      return Status::Error(ss.str());
    }
    return Status::OK();
  }

  Status checkLexicalError(const string& text, const std::string& errMsg) {
    auto input = [&text](char* buf, int) -> int {
      static bool first = true;
      if (!first) {
        return 0;
      }
      first = false;
      auto size = text.size();
      ::memcpy(buf, text.c_str(), size);
      return size;
    };
    GraphScanner lexer;
    lexer.setReadBuffer(input);
    nebula::GraphParser::semantic_type dummyyylval;
    nebula::GraphParser::location_type dummyyyloc;
    try {
      auto token = lexer.yylex(&dummyyylval, &dummyyyloc);
      if (token != 0) {
        std::ostringstream ss;
        ss << "Lexical error should've "
           << "happened for `" << text << "'";
        return Status::Error(ss.str());
      }
    } catch (const std::exception& e) {
      auto actualErrMsg = e.what();
      if (errMsg != actualErrMsg) {
        std::ostringstream ss;
        ss << "Error message not match, "
           << "expected: " << errMsg << ", actual: " << actualErrMsg;
        return Status::Error(ss.str());
      }
    }
    return Status::OK();
  }

  void consumeZero() {
    auto actual = scanner_.yylex(&yylval_, &yyloc_);
    ASSERT_TRUE(actual == Token::TOK_ZERO);
  }

 private:
  nebula::GraphParser::semantic_type yylval_;
  nebula::GraphParser::location_type yyloc_;
  GraphScanner scanner_;
  std::string stream_;
  int copied_{0};
};

TEST_F(ScannerTest, Operator) {
  CHECK_SEMANTIC_TYPE("&", Token::TOK_AMPERSAND);
  CHECK_SEMANTIC_TYPE("*", Token::TOK_ASTERISK);
  CHECK_SEMANTIC_TYPE(":", Token::TOK_COLON);
  CHECK_SEMANTIC_TYPE(",", Token::TOK_COMMA);
  CHECK_SEMANTIC_TYPE("$", Token::TOK_DOLLAR_SIGN);
  CHECK_SEMANTIC_TYPE("=", Token::TOK_EQUALS_OPERATOR);
  CHECK_SEMANTIC_TYPE("!", Token::TOK_EXCLAMATION_MARK);
  CHECK_SEMANTIC_TYPE(">", Token::TOK_RIGHT_ANGLE_BRACKET);
  CHECK_SEMANTIC_TYPE("{", Token::TOK_LEFT_BRACE);
  CHECK_SEMANTIC_TYPE("[", Token::TOK_LEFT_BRACKET);
  CHECK_SEMANTIC_TYPE("(", Token::TOK_LEFT_PAREN);
  CHECK_SEMANTIC_TYPE("<", Token::TOK_LEFT_ANGLE_BRACKET);
  CHECK_SEMANTIC_TYPE("-", Token::TOK_MINUS_SIGN);
  CHECK_SEMANTIC_TYPE("%", Token::TOK_PERCENT);
  CHECK_SEMANTIC_TYPE(".", Token::TOK_PERIOD);
  CHECK_SEMANTIC_TYPE("+", Token::TOK_PLUS_SIGN);
  CHECK_SEMANTIC_TYPE("?", Token::TOK_QUESTION_MARK);
  CHECK_SEMANTIC_TYPE("}", Token::TOK_RIGHT_BRACE);
  CHECK_SEMANTIC_TYPE("]", Token::TOK_RIGHT_BRACKET);
  CHECK_SEMANTIC_TYPE(")", Token::TOK_RIGHT_PAREN);
  CHECK_SEMANTIC_TYPE(";", Token::TOK_SEMICOLON);
  CHECK_SEMANTIC_TYPE("/", Token::TOK_SOLIDUS);
  CHECK_SEMANTIC_TYPE("~", Token::TOK_TILDE);
  CHECK_SEMANTIC_TYPE("|", Token::TOK_VERTICAL_BAR);
  CHECK_SEMANTIC_TYPE("]->", Token::TOK_BRACKET_RIGHT_ARROW);
  CHECK_SEMANTIC_TYPE("]~>", Token::TOK_BRACKET_TILDE_RIGHT_ARROW);
  CHECK_SEMANTIC_TYPE("||", Token::TOK_CONCATENATION_OPERATOR);
  CHECK_SEMANTIC_TYPE("::", Token::TOK_DOUBLE_COLON);
  CHECK_SEMANTIC_TYPE("..", Token::TOK_DOUBLE_PERIOD);
  CHECK_SEMANTIC_TYPE(">=", Token::TOK_GREATER_THAN_OR_EQUALS_OPERATOR);
  CHECK_SEMANTIC_TYPE("<-", Token::TOK_LEFT_ARROW);
  CHECK_SEMANTIC_TYPE("<~", Token::TOK_LEFT_ARROW_TILDE);
  CHECK_SEMANTIC_TYPE("<-[", Token::TOK_LEFT_ARROW_BRACKET);
  CHECK_SEMANTIC_TYPE("<~[", Token::TOK_LEFT_ARROW_TILDE_BRACKET);
  CHECK_SEMANTIC_TYPE("<->", Token::TOK_LEFT_MINUS_RIGHT);
  CHECK_SEMANTIC_TYPE("<-/", Token::TOK_LEFT_MINUS_SLASH);
  CHECK_SEMANTIC_TYPE("<~/", Token::TOK_LEFT_TILDE_SLASH);
  CHECK_SEMANTIC_TYPE("<=", Token::TOK_LESS_THAN_OR_EQUALS_OPERATOR);
  CHECK_SEMANTIC_TYPE("-[", Token::TOK_MINUS_LEFT_BRACKET);
  CHECK_SEMANTIC_TYPE("-/", Token::TOK_MINUS_SLASH);
  CHECK_SEMANTIC_TYPE("<>", Token::TOK_NOT_EQUALS_OPERATOR);
  CHECK_SEMANTIC_TYPE("->", Token::TOK_RIGHT_ARROW);
  CHECK_SEMANTIC_TYPE("]-", Token::TOK_RIGHT_BRACKET_MINUS);
  CHECK_SEMANTIC_TYPE("]~", Token::TOK_RIGHT_BRACKET_TILDE);
  CHECK_SEMANTIC_TYPE("/-", Token::TOK_SLASH_MINUS);
  CHECK_SEMANTIC_TYPE("/->", Token::TOK_SLASH_MINUS_RIGHT);
  CHECK_SEMANTIC_TYPE("/~", Token::TOK_SLASH_TILDE);
  CHECK_SEMANTIC_TYPE("/~>", Token::TOK_SLASH_TILDE_RIGHT);
  CHECK_SEMANTIC_TYPE("~[", Token::TOK_TILDE_LEFT_BRACKET);
  CHECK_SEMANTIC_TYPE("~>", Token::TOK_TILDE_RIGHT_ARROW);
  CHECK_SEMANTIC_TYPE("~/", Token::TOK_TILDE_SLASH);
  CHECK_SEMANTIC_TYPE("|+|", Token::TOK_MULTISET_ALTERNATION_OPERATOR);
}

TEST_F(ScannerTest, CaseSensitiveReservedKeyword) {
  CHECK_SEMANTIC_TYPE("endNode", Token::TOK_endNode);
  CHECK_SEMANTIC_TYPE("inDegree", Token::TOK_inDegree);
  CHECK_SEMANTIC_TYPE("lTrim", Token::TOK_lTrim);
  CHECK_SEMANTIC_TYPE("outDegree", Token::TOK_outDegree);
  CHECK_SEMANTIC_TYPE("percentileCont", Token::TOK_percentileCont);
  CHECK_SEMANTIC_TYPE("percentileDist", Token::TOK_percentileDist);
  CHECK_SEMANTIC_TYPE("rTrim", Token::TOK_rTrim);
  CHECK_SEMANTIC_TYPE("startNode", Token::TOK_startNode);
  CHECK_SEMANTIC_TYPE("stDev", Token::TOK_stDev);
  CHECK_SEMANTIC_TYPE("stDevP", Token::TOK_stDevP);
  CHECK_SEMANTIC_TYPE("tail", Token::TOK_tail);
  CHECK_SEMANTIC_TYPE("toLower", Token::TOK_toLower);
  CHECK_SEMANTIC_TYPE("toUpper", Token::TOK_toUpper);
}

TEST_F(ScannerTest, CaseInsensitiveReservedKeyword) {
  CHECK_SEMANTIC_TYPE("ABS", Token::TOK_ABS);
  CHECK_SEMANTIC_TYPE("abs", Token::TOK_ABS);
  CHECK_SEMANTIC_TYPE("aBs", Token::TOK_ABS);
  CHECK_SEMANTIC_TYPE("ACOS", Token::TOK_ACOS);
  CHECK_SEMANTIC_TYPE("acos", Token::TOK_ACOS);
  CHECK_SEMANTIC_TYPE("aCos", Token::TOK_ACOS);
  CHECK_SEMANTIC_TYPE("ADD", Token::TOK_ADD);
  CHECK_SEMANTIC_TYPE("add", Token::TOK_ADD);
  CHECK_SEMANTIC_TYPE("aDD", Token::TOK_ADD);
  CHECK_SEMANTIC_TYPE("AGGREGATE", Token::TOK_AGGREGATE);
  CHECK_SEMANTIC_TYPE("aggregate", Token::TOK_AGGREGATE);
  CHECK_SEMANTIC_TYPE("aGGREGATE", Token::TOK_AGGREGATE);
  CHECK_SEMANTIC_TYPE("ALIAS", Token::TOK_ALIAS);
  CHECK_SEMANTIC_TYPE("alias", Token::TOK_ALIAS);
  CHECK_SEMANTIC_TYPE("aLias", Token::TOK_ALIAS);
  CHECK_SEMANTIC_TYPE("ALL", Token::TOK_ALL);
  CHECK_SEMANTIC_TYPE("all", Token::TOK_ALL);
  CHECK_SEMANTIC_TYPE("aLL", Token::TOK_ALL);
  CHECK_SEMANTIC_TYPE("ALL_DIFFERENT", Token::TOK_ALL_DIFFERENT);
  CHECK_SEMANTIC_TYPE("all_different", Token::TOK_ALL_DIFFERENT);
  CHECK_SEMANTIC_TYPE("All_diFFerent", Token::TOK_ALL_DIFFERENT);
  CHECK_SEMANTIC_TYPE("AND", Token::TOK_AND);
  CHECK_SEMANTIC_TYPE("and", Token::TOK_AND);
  CHECK_SEMANTIC_TYPE("aND", Token::TOK_AND);
  CHECK_SEMANTIC_TYPE("ANY", Token::TOK_ANY);
  CHECK_SEMANTIC_TYPE("any", Token::TOK_ANY);
  CHECK_SEMANTIC_TYPE("aNY", Token::TOK_ANY);
  CHECK_SEMANTIC_TYPE("ARRAY", Token::TOK_ARRAY);
  CHECK_SEMANTIC_TYPE("array", Token::TOK_ARRAY);
  CHECK_SEMANTIC_TYPE("ArrAY", Token::TOK_ARRAY);
  CHECK_SEMANTIC_TYPE("AS", Token::TOK_AS);
  CHECK_SEMANTIC_TYPE("as", Token::TOK_AS);
  CHECK_SEMANTIC_TYPE("aS", Token::TOK_AS);
  CHECK_SEMANTIC_TYPE("ASC", Token::TOK_ASC);
  CHECK_SEMANTIC_TYPE("asc", Token::TOK_ASC);
  CHECK_SEMANTIC_TYPE("aSC", Token::TOK_ASC);
  CHECK_SEMANTIC_TYPE("ASCENDING", Token::TOK_ASCENDING);
  CHECK_SEMANTIC_TYPE("ascending", Token::TOK_ASCENDING);
  CHECK_SEMANTIC_TYPE("aSCENdING", Token::TOK_ASCENDING);
  CHECK_SEMANTIC_TYPE("ASIN", Token::TOK_ASIN);
  CHECK_SEMANTIC_TYPE("asin", Token::TOK_ASIN);
  CHECK_SEMANTIC_TYPE("AsIn", Token::TOK_ASIN);
  CHECK_SEMANTIC_TYPE("AT", Token::TOK_AT);
  CHECK_SEMANTIC_TYPE("at", Token::TOK_AT);
  CHECK_SEMANTIC_TYPE("At", Token::TOK_AT);
  CHECK_SEMANTIC_TYPE("ATAN", Token::TOK_ATAN);
  CHECK_SEMANTIC_TYPE("atan", Token::TOK_ATAN);
  CHECK_SEMANTIC_TYPE("AtAn", Token::TOK_ATAN);
  CHECK_SEMANTIC_TYPE("AVG", Token::TOK_AVG);
  CHECK_SEMANTIC_TYPE("avg", Token::TOK_AVG);
  CHECK_SEMANTIC_TYPE("aVg", Token::TOK_AVG);
  CHECK_SEMANTIC_TYPE("BINARY", Token::TOK_BINARY);
  CHECK_SEMANTIC_TYPE("binary", Token::TOK_BINARY);
  CHECK_SEMANTIC_TYPE("BinaRY", Token::TOK_BINARY);
  CHECK_SEMANTIC_TYPE("BIGINT", Token::TOK_BIGINT);
  CHECK_SEMANTIC_TYPE("bigint", Token::TOK_BIGINT);
  CHECK_SEMANTIC_TYPE("bigINT", Token::TOK_BIGINT);
  CHECK_SEMANTIC_TYPE("BOOL", Token::TOK_BOOL);
  CHECK_SEMANTIC_TYPE("bool", Token::TOK_BOOL);
  CHECK_SEMANTIC_TYPE("bOOL", Token::TOK_BOOL);
  CHECK_SEMANTIC_TYPE("BOOLEAN", Token::TOK_BOOLEAN);
  CHECK_SEMANTIC_TYPE("boolean", Token::TOK_BOOLEAN);
  CHECK_SEMANTIC_TYPE("bOOLeaN", Token::TOK_BOOLEAN);
  CHECK_SEMANTIC_TYPE("BOTH", Token::TOK_BOTH);
  CHECK_SEMANTIC_TYPE("both", Token::TOK_BOTH);
  CHECK_SEMANTIC_TYPE("bOth", Token::TOK_BOTH);
  CHECK_SEMANTIC_TYPE("BY", Token::TOK_BY);
  CHECK_SEMANTIC_TYPE("by", Token::TOK_BY);
  CHECK_SEMANTIC_TYPE("By", Token::TOK_BY);
  CHECK_SEMANTIC_TYPE("BYTE_LENGTH", Token::TOK_BYTE_LENGTH);
  CHECK_SEMANTIC_TYPE("byte_length", Token::TOK_BYTE_LENGTH);
  CHECK_SEMANTIC_TYPE("Byte_lengTH", Token::TOK_BYTE_LENGTH);
  CHECK_SEMANTIC_TYPE("BYTES", Token::TOK_BYTES);
  CHECK_SEMANTIC_TYPE("bytes", Token::TOK_BYTES);
  CHECK_SEMANTIC_TYPE("ByTes", Token::TOK_BYTES);
  CHECK_SEMANTIC_TYPE("CALL", Token::TOK_CALL);
  CHECK_SEMANTIC_TYPE("call", Token::TOK_CALL);
  CHECK_SEMANTIC_TYPE("CaLL", Token::TOK_CALL);
  CHECK_SEMANTIC_TYPE("CASE", Token::TOK_CASE);
  CHECK_SEMANTIC_TYPE("case", Token::TOK_CASE);
  CHECK_SEMANTIC_TYPE("cASE", Token::TOK_CASE);
  CHECK_SEMANTIC_TYPE("CAST", Token::TOK_CAST);
  CHECK_SEMANTIC_TYPE("cast", Token::TOK_CAST);
  CHECK_SEMANTIC_TYPE("CaSt", Token::TOK_CAST);
  CHECK_SEMANTIC_TYPE("CATALOG", Token::TOK_CATALOG);
  CHECK_SEMANTIC_TYPE("catalog", Token::TOK_CATALOG);
  CHECK_SEMANTIC_TYPE("CaTALOG", Token::TOK_CATALOG);
  CHECK_SEMANTIC_TYPE("CEIL", Token::TOK_CEIL);
  CHECK_SEMANTIC_TYPE("ceil", Token::TOK_CEIL);
  CHECK_SEMANTIC_TYPE("CeIl", Token::TOK_CEIL);
  CHECK_SEMANTIC_TYPE("CEILING", Token::TOK_CEILING);
  CHECK_SEMANTIC_TYPE("ceiling", Token::TOK_CEILING);
  CHECK_SEMANTIC_TYPE("CeILING", Token::TOK_CEILING);
  CHECK_SEMANTIC_TYPE("CHARACTER", Token::TOK_CHARACTER);
  CHECK_SEMANTIC_TYPE("character", Token::TOK_CHARACTER);
  CHECK_SEMANTIC_TYPE("chARActer", Token::TOK_CHARACTER);
  CHECK_SEMANTIC_TYPE("CHARACTER_LENGTH", Token::TOK_CHARACTER_LENGTH);
  CHECK_SEMANTIC_TYPE("character_length", Token::TOK_CHARACTER_LENGTH);
  CHECK_SEMANTIC_TYPE("ChAraCTER_LenGTH", Token::TOK_CHARACTER_LENGTH);
  CHECK_SEMANTIC_TYPE("CLEAR", Token::TOK_CLEAR);
  CHECK_SEMANTIC_TYPE("clear", Token::TOK_CLEAR);
  CHECK_SEMANTIC_TYPE("ClEAR", Token::TOK_CLEAR);
  CHECK_SEMANTIC_TYPE("CLONE", Token::TOK_CLONE);
  CHECK_SEMANTIC_TYPE("clone", Token::TOK_CLONE);
  CHECK_SEMANTIC_TYPE("ClONE", Token::TOK_CLONE);
  CHECK_SEMANTIC_TYPE("CLOSE", Token::TOK_CLOSE);
  CHECK_SEMANTIC_TYPE("close", Token::TOK_CLOSE);
  CHECK_SEMANTIC_TYPE("CloSE", Token::TOK_CLOSE);
  CHECK_SEMANTIC_TYPE("COALESCE", Token::TOK_COALESCE);
  CHECK_SEMANTIC_TYPE("coalesce", Token::TOK_COALESCE);
  CHECK_SEMANTIC_TYPE("CoALESCE", Token::TOK_COALESCE);
  CHECK_SEMANTIC_TYPE("COLLECT", Token::TOK_COLLECT);
  CHECK_SEMANTIC_TYPE("collect", Token::TOK_COLLECT);
  CHECK_SEMANTIC_TYPE("CoLLECT", Token::TOK_COLLECT);
  CHECK_SEMANTIC_TYPE("COMMIT", Token::TOK_COMMIT);
  CHECK_SEMANTIC_TYPE("commit", Token::TOK_COMMIT);
  CHECK_SEMANTIC_TYPE("CoMMIT", Token::TOK_COMMIT);
  CHECK_SEMANTIC_TYPE("CONSTRAINT", Token::TOK_CONSTRAINT);
  CHECK_SEMANTIC_TYPE("constraint", Token::TOK_CONSTRAINT);
  CHECK_SEMANTIC_TYPE("CoNSTRAINT", Token::TOK_CONSTRAINT);
  CHECK_SEMANTIC_TYPE("CONSTANT", Token::TOK_CONSTANT);
  CHECK_SEMANTIC_TYPE("constant", Token::TOK_CONSTANT);
  CHECK_SEMANTIC_TYPE("CoNSTANT", Token::TOK_CONSTANT);
  CHECK_SEMANTIC_TYPE("CONSTRUCT", Token::TOK_CONSTRUCT);
  CHECK_SEMANTIC_TYPE("construct", Token::TOK_CONSTRUCT);
  CHECK_SEMANTIC_TYPE("CoNSTRUCT", Token::TOK_CONSTRUCT);
  CHECK_SEMANTIC_TYPE("COPY", Token::TOK_COPY);
  CHECK_SEMANTIC_TYPE("copy", Token::TOK_COPY);
  CHECK_SEMANTIC_TYPE("CoPy", Token::TOK_COPY);
  CHECK_SEMANTIC_TYPE("COS", Token::TOK_COS);
  CHECK_SEMANTIC_TYPE("cos", Token::TOK_COS);
  CHECK_SEMANTIC_TYPE("CoS", Token::TOK_COS);
  CHECK_SEMANTIC_TYPE("COSH", Token::TOK_COSH);
  CHECK_SEMANTIC_TYPE("cosh", Token::TOK_COSH);
  CHECK_SEMANTIC_TYPE("CoSH", Token::TOK_COSH);
  CHECK_SEMANTIC_TYPE("COST", Token::TOK_COST);
  CHECK_SEMANTIC_TYPE("cost", Token::TOK_COST);
  CHECK_SEMANTIC_TYPE("CoST", Token::TOK_COST);
  CHECK_SEMANTIC_TYPE("COT", Token::TOK_COT);
  CHECK_SEMANTIC_TYPE("cot", Token::TOK_COT);
  CHECK_SEMANTIC_TYPE("CoT", Token::TOK_COT);
  CHECK_SEMANTIC_TYPE("COUNT", Token::TOK_COUNT);
  CHECK_SEMANTIC_TYPE("count", Token::TOK_COUNT);
  CHECK_SEMANTIC_TYPE("CoUnt", Token::TOK_COUNT);
  CHECK_SEMANTIC_TYPE("CURRENT_DATE", Token::TOK_CURRENT_DATE);
  CHECK_SEMANTIC_TYPE("current_date", Token::TOK_CURRENT_DATE);
  CHECK_SEMANTIC_TYPE("CuRrent_DATE", Token::TOK_CURRENT_DATE);
  CHECK_SEMANTIC_TYPE("CURRENT_GRAPH", Token::TOK_CURRENT_GRAPH);
  CHECK_SEMANTIC_TYPE("current_graph", Token::TOK_CURRENT_GRAPH);
  CHECK_SEMANTIC_TYPE("CuRrent_Graph", Token::TOK_CURRENT_GRAPH);
  CHECK_SEMANTIC_TYPE("CURRENT_PROPERTY_GRAPH", Token::TOK_CURRENT_PROPERTY_GRAPH);
  CHECK_SEMANTIC_TYPE("current_property_graph", Token::TOK_CURRENT_PROPERTY_GRAPH);
  CHECK_SEMANTIC_TYPE("CuRrent_Property_Graph", Token::TOK_CURRENT_PROPERTY_GRAPH);
  CHECK_SEMANTIC_TYPE("CURRENT_ROLE", Token::TOK_CURRENT_ROLE);
  CHECK_SEMANTIC_TYPE("current_role", Token::TOK_CURRENT_ROLE);
  CHECK_SEMANTIC_TYPE("CuRrent_Role", Token::TOK_CURRENT_ROLE);
  CHECK_SEMANTIC_TYPE("CURRENT_SCHEMA", Token::TOK_CURRENT_SCHEMA);
  CHECK_SEMANTIC_TYPE("current_schema", Token::TOK_CURRENT_SCHEMA);
  CHECK_SEMANTIC_TYPE("CuRrent_Schema", Token::TOK_CURRENT_SCHEMA);
  CHECK_SEMANTIC_TYPE("CURRENT_TIME", Token::TOK_CURRENT_TIME);
  CHECK_SEMANTIC_TYPE("current_time", Token::TOK_CURRENT_TIME);
  CHECK_SEMANTIC_TYPE("CuRrent_Time", Token::TOK_CURRENT_TIME);
  CHECK_SEMANTIC_TYPE("CURRENT_TIMESTAMP", Token::TOK_CURRENT_TIMESTAMP);
  CHECK_SEMANTIC_TYPE("current_timestamp", Token::TOK_CURRENT_TIMESTAMP);
  CHECK_SEMANTIC_TYPE("CuRrent_Timestamp", Token::TOK_CURRENT_TIMESTAMP);
  CHECK_SEMANTIC_TYPE("CURRENT_USER", Token::TOK_CURRENT_USER);
  CHECK_SEMANTIC_TYPE("current_user", Token::TOK_CURRENT_USER);
  CHECK_SEMANTIC_TYPE("CuRrent_User", Token::TOK_CURRENT_USER);
  CHECK_SEMANTIC_TYPE("CREATE", Token::TOK_CREATE);
  CHECK_SEMANTIC_TYPE("create", Token::TOK_CREATE);
  CHECK_SEMANTIC_TYPE("CrEATE", Token::TOK_CREATE);
  CHECK_SEMANTIC_TYPE("DATA", Token::TOK_DATA);
  CHECK_SEMANTIC_TYPE("data", Token::TOK_DATA);
  CHECK_SEMANTIC_TYPE("DaTa", Token::TOK_DATA);
  CHECK_SEMANTIC_TYPE("DATE", Token::TOK_DATE);
  CHECK_SEMANTIC_TYPE("date", Token::TOK_DATE);
  CHECK_SEMANTIC_TYPE("DaTe", Token::TOK_DATE);
  CHECK_SEMANTIC_TYPE("DATETIME", Token::TOK_DATETIME);
  CHECK_SEMANTIC_TYPE("datetime", Token::TOK_DATETIME);
  CHECK_SEMANTIC_TYPE("DaTeTiMe", Token::TOK_DATETIME);
  CHECK_SEMANTIC_TYPE("DAY", Token::TOK_DAY);
  CHECK_SEMANTIC_TYPE("day", Token::TOK_DAY);
  CHECK_SEMANTIC_TYPE("DaY", Token::TOK_DAY);
  CHECK_SEMANTIC_TYPE("DEC", Token::TOK_DEC);
  CHECK_SEMANTIC_TYPE("dec", Token::TOK_DEC);
  CHECK_SEMANTIC_TYPE("DeC", Token::TOK_DEC);
  CHECK_SEMANTIC_TYPE("DECIMAL", Token::TOK_DECIMAL);
  CHECK_SEMANTIC_TYPE("decimal", Token::TOK_DECIMAL);
  CHECK_SEMANTIC_TYPE("DeCiMal", Token::TOK_DECIMAL);
  CHECK_SEMANTIC_TYPE("DEFAULT", Token::TOK_DEFAULT);
  CHECK_SEMANTIC_TYPE("default", Token::TOK_DEFAULT);
  CHECK_SEMANTIC_TYPE("DeFault", Token::TOK_DEFAULT);
  CHECK_SEMANTIC_TYPE("DEGREES", Token::TOK_DEGREES);
  CHECK_SEMANTIC_TYPE("degrees", Token::TOK_DEGREES);
  CHECK_SEMANTIC_TYPE("DeGREES", Token::TOK_DEGREES);
  CHECK_SEMANTIC_TYPE("DELETE", Token::TOK_DELETE);
  CHECK_SEMANTIC_TYPE("delete", Token::TOK_DELETE);
  CHECK_SEMANTIC_TYPE("DeLETE", Token::TOK_DELETE);
  CHECK_SEMANTIC_TYPE("DETACH", Token::TOK_DETACH);
  CHECK_SEMANTIC_TYPE("detach", Token::TOK_DETACH);
  CHECK_SEMANTIC_TYPE("DeTACH", Token::TOK_DETACH);
  CHECK_SEMANTIC_TYPE("DESC", Token::TOK_DESC);
  CHECK_SEMANTIC_TYPE("desc", Token::TOK_DESC);
  CHECK_SEMANTIC_TYPE("DeSC", Token::TOK_DESC);
  CHECK_SEMANTIC_TYPE("DESCENDING", Token::TOK_DESCENDING);
  CHECK_SEMANTIC_TYPE("descending", Token::TOK_DESCENDING);
  CHECK_SEMANTIC_TYPE("DeSCENDING", Token::TOK_DESCENDING);
  CHECK_SEMANTIC_TYPE("DIRECTORIES", Token::TOK_DIRECTORIES);
  CHECK_SEMANTIC_TYPE("directories", Token::TOK_DIRECTORIES);
  CHECK_SEMANTIC_TYPE("DiRECTORIEs", Token::TOK_DIRECTORIES);
  CHECK_SEMANTIC_TYPE("DIRECTORY", Token::TOK_DIRECTORY);
  CHECK_SEMANTIC_TYPE("directory", Token::TOK_DIRECTORY);
  CHECK_SEMANTIC_TYPE("DiRECTORY", Token::TOK_DIRECTORY);
  CHECK_SEMANTIC_TYPE("DISTINCT", Token::TOK_DISTINCT);
  CHECK_SEMANTIC_TYPE("distinct", Token::TOK_DISTINCT);
  CHECK_SEMANTIC_TYPE("DiSTinct", Token::TOK_DISTINCT);
  CHECK_SEMANTIC_TYPE("DO", Token::TOK_DO);
  CHECK_SEMANTIC_TYPE("do", Token::TOK_DO);
  CHECK_SEMANTIC_TYPE("Do", Token::TOK_DO);
  CHECK_SEMANTIC_TYPE("DOUBLE", Token::TOK_DOUBLE);
  CHECK_SEMANTIC_TYPE("double", Token::TOK_DOUBLE);
  CHECK_SEMANTIC_TYPE("Double", Token::TOK_DOUBLE);
  CHECK_SEMANTIC_TYPE("DROP", Token::TOK_DROP);
  CHECK_SEMANTIC_TYPE("drop", Token::TOK_DROP);
  CHECK_SEMANTIC_TYPE("DroP", Token::TOK_DROP);
  CHECK_SEMANTIC_TYPE("DURATION", Token::TOK_DURATION);
  CHECK_SEMANTIC_TYPE("duration", Token::TOK_DURATION);
  CHECK_SEMANTIC_TYPE("DuRATION", Token::TOK_DURATION);
  CHECK_SEMANTIC_TYPE("ELEMENT_ID", Token::TOK_ELEMENT_ID);
  CHECK_SEMANTIC_TYPE("element_id", Token::TOK_ELEMENT_ID);
  CHECK_SEMANTIC_TYPE("ELEMENT_id", Token::TOK_ELEMENT_ID);
  CHECK_SEMANTIC_TYPE("ELSE", Token::TOK_ELSE);
  CHECK_SEMANTIC_TYPE("else", Token::TOK_ELSE);
  CHECK_SEMANTIC_TYPE("ElsE", Token::TOK_ELSE);
  CHECK_SEMANTIC_TYPE("END", Token::TOK_END);
  CHECK_SEMANTIC_TYPE("end", Token::TOK_END);
  CHECK_SEMANTIC_TYPE("EnD", Token::TOK_END);
  CHECK_SEMANTIC_TYPE("ENDS", Token::TOK_ENDS);
  CHECK_SEMANTIC_TYPE("ends", Token::TOK_ENDS);
  CHECK_SEMANTIC_TYPE("EnDS", Token::TOK_ENDS);
  CHECK_SEMANTIC_TYPE("EMPTY_BINDING_TABLE", Token::TOK_EMPTY_BINDING_TABLE);
  CHECK_SEMANTIC_TYPE("empty_binding_table", Token::TOK_EMPTY_BINDING_TABLE);
  CHECK_SEMANTIC_TYPE("EMPTY_BINDING_taBLE", Token::TOK_EMPTY_BINDING_TABLE);
  CHECK_SEMANTIC_TYPE("EMPTY_GRAPH", Token::TOK_EMPTY_GRAPH);
  CHECK_SEMANTIC_TYPE("empty_graph", Token::TOK_EMPTY_GRAPH);
  CHECK_SEMANTIC_TYPE("Empty_Graph", Token::TOK_EMPTY_GRAPH);
  CHECK_SEMANTIC_TYPE("EMPTY_PROPERTY_GRAPH", Token::TOK_EMPTY_PROPERTY_GRAPH);
  CHECK_SEMANTIC_TYPE("empty_property_graph", Token::TOK_EMPTY_PROPERTY_GRAPH);
  CHECK_SEMANTIC_TYPE("Empty_Property_Graph", Token::TOK_EMPTY_PROPERTY_GRAPH);
  CHECK_SEMANTIC_TYPE("EMPTY_TABLE", Token::TOK_EMPTY_TABLE);
  CHECK_SEMANTIC_TYPE("empty_table", Token::TOK_EMPTY_TABLE);
  CHECK_SEMANTIC_TYPE("Empty_Table", Token::TOK_EMPTY_TABLE);
  CHECK_SEMANTIC_TYPE("EXCEPT", Token::TOK_EXCEPT);
  CHECK_SEMANTIC_TYPE("except", Token::TOK_EXCEPT);
  CHECK_SEMANTIC_TYPE("ExCEPT", Token::TOK_EXCEPT);
  CHECK_SEMANTIC_TYPE("EXISTS", Token::TOK_EXISTS);
  CHECK_SEMANTIC_TYPE("exists", Token::TOK_EXISTS);
  CHECK_SEMANTIC_TYPE("ExISTS", Token::TOK_EXISTS);
  CHECK_SEMANTIC_TYPE("EXISTING", Token::TOK_EXISTING);
  CHECK_SEMANTIC_TYPE("existing", Token::TOK_EXISTING);
  CHECK_SEMANTIC_TYPE("ExISTING", Token::TOK_EXISTING);
  CHECK_SEMANTIC_TYPE("EXP", Token::TOK_EXP);
  CHECK_SEMANTIC_TYPE("exp", Token::TOK_EXP);
  CHECK_SEMANTIC_TYPE("Exp", Token::TOK_EXP);
  CHECK_SEMANTIC_TYPE("EXPLAIN", Token::TOK_EXPLAIN);
  CHECK_SEMANTIC_TYPE("explain", Token::TOK_EXPLAIN);
  CHECK_SEMANTIC_TYPE("exPlain", Token::TOK_EXPLAIN);
  CHECK_SEMANTIC_TYPE("FALSE", Token::TOK_FALSE);
  CHECK_SEMANTIC_TYPE("false", Token::TOK_FALSE);
  CHECK_SEMANTIC_TYPE("FaLSE", Token::TOK_FALSE);
  CHECK_SEMANTIC_TYPE("FILTER", Token::TOK_FILTER);
  CHECK_SEMANTIC_TYPE("filter", Token::TOK_FILTER);
  CHECK_SEMANTIC_TYPE("Filter", Token::TOK_FILTER);
  CHECK_SEMANTIC_TYPE("FLOAT", Token::TOK_FLOAT);
  CHECK_SEMANTIC_TYPE("float", Token::TOK_FLOAT);
  CHECK_SEMANTIC_TYPE("Float", Token::TOK_FLOAT);
  CHECK_SEMANTIC_TYPE("FLOAT16", Token::TOK_FLOAT16);
  CHECK_SEMANTIC_TYPE("float16", Token::TOK_FLOAT16);
  CHECK_SEMANTIC_TYPE("Float16", Token::TOK_FLOAT16);
  CHECK_SEMANTIC_TYPE("FLOAT32", Token::TOK_FLOAT32);
  CHECK_SEMANTIC_TYPE("float32", Token::TOK_FLOAT32);
  CHECK_SEMANTIC_TYPE("Float32", Token::TOK_FLOAT32);
  CHECK_SEMANTIC_TYPE("FLOAT64", Token::TOK_FLOAT64);
  CHECK_SEMANTIC_TYPE("float64", Token::TOK_FLOAT64);
  CHECK_SEMANTIC_TYPE("Float64", Token::TOK_FLOAT64);
  CHECK_SEMANTIC_TYPE("FLOAT128", Token::TOK_FLOAT128);
  CHECK_SEMANTIC_TYPE("float128", Token::TOK_FLOAT128);
  CHECK_SEMANTIC_TYPE("Float128", Token::TOK_FLOAT128);
  CHECK_SEMANTIC_TYPE("FLOAT256", Token::TOK_FLOAT256);
  CHECK_SEMANTIC_TYPE("float256", Token::TOK_FLOAT256);
  CHECK_SEMANTIC_TYPE("Float256", Token::TOK_FLOAT256);
  CHECK_SEMANTIC_TYPE("FLOOR", Token::TOK_FLOOR);
  CHECK_SEMANTIC_TYPE("floor", Token::TOK_FLOOR);
  CHECK_SEMANTIC_TYPE("Floor", Token::TOK_FLOOR);
  CHECK_SEMANTIC_TYPE("FOR", Token::TOK_FOR);
  CHECK_SEMANTIC_TYPE("for", Token::TOK_FOR);
  CHECK_SEMANTIC_TYPE("For", Token::TOK_FOR);
  CHECK_SEMANTIC_TYPE("FROM", Token::TOK_FROM);
  CHECK_SEMANTIC_TYPE("from", Token::TOK_FROM);
  CHECK_SEMANTIC_TYPE("From", Token::TOK_FROM);
  CHECK_SEMANTIC_TYPE("FUNCTION", Token::TOK_FUNCTION);
  CHECK_SEMANTIC_TYPE("function", Token::TOK_FUNCTION);
  CHECK_SEMANTIC_TYPE("Function", Token::TOK_FUNCTION);
  CHECK_SEMANTIC_TYPE("FUNCTIONS", Token::TOK_FUNCTIONS);
  CHECK_SEMANTIC_TYPE("functions", Token::TOK_FUNCTIONS);
  CHECK_SEMANTIC_TYPE("Functions", Token::TOK_FUNCTIONS);
  CHECK_SEMANTIC_TYPE("GQLSTATUS", Token::TOK_GQLSTATUS);
  CHECK_SEMANTIC_TYPE("gqlstatus", Token::TOK_GQLSTATUS);
  CHECK_SEMANTIC_TYPE("GQLStatus", Token::TOK_GQLSTATUS);
  CHECK_SEMANTIC_TYPE("GRANT", Token::TOK_GRANT);
  CHECK_SEMANTIC_TYPE("grant", Token::TOK_GRANT);
  CHECK_SEMANTIC_TYPE("Grant", Token::TOK_GRANT);
  CHECK_SEMANTIC_TYPE("GROUP", Token::TOK_GROUP);
  CHECK_SEMANTIC_TYPE("group", Token::TOK_GROUP);
  CHECK_SEMANTIC_TYPE("Group", Token::TOK_GROUP);
  CHECK_SEMANTIC_TYPE("HAVING", Token::TOK_HAVING);
  CHECK_SEMANTIC_TYPE("having", Token::TOK_HAVING);
  CHECK_SEMANTIC_TYPE("Having", Token::TOK_HAVING);
  CHECK_SEMANTIC_TYPE("HOME_GRAPH", Token::TOK_HOME_GRAPH);
  CHECK_SEMANTIC_TYPE("home_graph", Token::TOK_HOME_GRAPH);
  CHECK_SEMANTIC_TYPE("Home_Graph", Token::TOK_HOME_GRAPH);
  CHECK_SEMANTIC_TYPE("HOME_PROPERTY_GRAPH", Token::TOK_HOME_PROPERTY_GRAPH);
  CHECK_SEMANTIC_TYPE("home_property_graph", Token::TOK_HOME_PROPERTY_GRAPH);
  CHECK_SEMANTIC_TYPE("Home_Property_Graph", Token::TOK_HOME_PROPERTY_GRAPH);
  CHECK_SEMANTIC_TYPE("HOME_SCHEMA", Token::TOK_HOME_SCHEMA);
  CHECK_SEMANTIC_TYPE("home_schema", Token::TOK_HOME_SCHEMA);
  CHECK_SEMANTIC_TYPE("Home_Schema", Token::TOK_HOME_SCHEMA);
  CHECK_SEMANTIC_TYPE("HOUR", Token::TOK_HOUR);
  CHECK_SEMANTIC_TYPE("hour", Token::TOK_HOUR);
  CHECK_SEMANTIC_TYPE("Hour", Token::TOK_HOUR);
  CHECK_SEMANTIC_TYPE("IN", Token::TOK_IN);
  CHECK_SEMANTIC_TYPE("in", Token::TOK_IN);
  CHECK_SEMANTIC_TYPE("In", Token::TOK_IN);
  CHECK_SEMANTIC_TYPE("INSERT", Token::TOK_INSERT);
  CHECK_SEMANTIC_TYPE("insert", Token::TOK_INSERT);
  CHECK_SEMANTIC_TYPE("Insert", Token::TOK_INSERT);
  CHECK_SEMANTIC_TYPE("INT", Token::TOK_INT);
  CHECK_SEMANTIC_TYPE("int", Token::TOK_INT);
  CHECK_SEMANTIC_TYPE("Int", Token::TOK_INT);
  CHECK_SEMANTIC_TYPE("INTEGER", Token::TOK_INTEGER);
  CHECK_SEMANTIC_TYPE("integer", Token::TOK_INTEGER);
  CHECK_SEMANTIC_TYPE("Integer", Token::TOK_INTEGER);
  CHECK_SEMANTIC_TYPE("INT8", Token::TOK_INT8);
  CHECK_SEMANTIC_TYPE("int8", Token::TOK_INT8);
  CHECK_SEMANTIC_TYPE("Int8", Token::TOK_INT8);
  CHECK_SEMANTIC_TYPE("INTEGER8", Token::TOK_INTEGER8);
  CHECK_SEMANTIC_TYPE("integer8", Token::TOK_INTEGER8);
  CHECK_SEMANTIC_TYPE("Integer8", Token::TOK_INTEGER8);
  CHECK_SEMANTIC_TYPE("INT16", Token::TOK_INT16);
  CHECK_SEMANTIC_TYPE("int16", Token::TOK_INT16);
  CHECK_SEMANTIC_TYPE("Int16", Token::TOK_INT16);
  CHECK_SEMANTIC_TYPE("INTEGER16", Token::TOK_INTEGER16);
  CHECK_SEMANTIC_TYPE("integer16", Token::TOK_INTEGER16);
  CHECK_SEMANTIC_TYPE("Integer16", Token::TOK_INTEGER16);
  CHECK_SEMANTIC_TYPE("INT32", Token::TOK_INT32);
  CHECK_SEMANTIC_TYPE("int32", Token::TOK_INT32);
  CHECK_SEMANTIC_TYPE("Int32", Token::TOK_INT32);
  CHECK_SEMANTIC_TYPE("INTEGER32", Token::TOK_INTEGER32);
  CHECK_SEMANTIC_TYPE("integer32", Token::TOK_INTEGER32);
  CHECK_SEMANTIC_TYPE("Integer32", Token::TOK_INTEGER32);
  CHECK_SEMANTIC_TYPE("INTERVAL", Token::TOK_INTERVAL);
  CHECK_SEMANTIC_TYPE("interval", Token::TOK_INTERVAL);
  CHECK_SEMANTIC_TYPE("Interval", Token::TOK_INTERVAL);
  CHECK_SEMANTIC_TYPE("INT64", Token::TOK_INT64);
  CHECK_SEMANTIC_TYPE("int64", Token::TOK_INT64);
  CHECK_SEMANTIC_TYPE("Int64", Token::TOK_INT64);
  CHECK_SEMANTIC_TYPE("INTEGER64", Token::TOK_INTEGER64);
  CHECK_SEMANTIC_TYPE("integer64", Token::TOK_INTEGER64);
  CHECK_SEMANTIC_TYPE("Integer64", Token::TOK_INTEGER64);
  CHECK_SEMANTIC_TYPE("INT128", Token::TOK_INT128);
  CHECK_SEMANTIC_TYPE("int128", Token::TOK_INT128);
  CHECK_SEMANTIC_TYPE("Int128", Token::TOK_INT128);
  CHECK_SEMANTIC_TYPE("INTEGER128", Token::TOK_INTEGER128);
  CHECK_SEMANTIC_TYPE("integer128", Token::TOK_INTEGER128);
  CHECK_SEMANTIC_TYPE("Integer128", Token::TOK_INTEGER128);
  CHECK_SEMANTIC_TYPE("INT256", Token::TOK_INT256);
  CHECK_SEMANTIC_TYPE("int256", Token::TOK_INT256);
  CHECK_SEMANTIC_TYPE("Int256", Token::TOK_INT256);
  CHECK_SEMANTIC_TYPE("INTEGER256", Token::TOK_INTEGER256);
  CHECK_SEMANTIC_TYPE("integer256", Token::TOK_INTEGER256);
  CHECK_SEMANTIC_TYPE("Integer256", Token::TOK_INTEGER256);
  CHECK_SEMANTIC_TYPE("INTERSECT", Token::TOK_INTERSECT);
  CHECK_SEMANTIC_TYPE("intersect", Token::TOK_INTERSECT);
  CHECK_SEMANTIC_TYPE("Intersect", Token::TOK_INTERSECT);
  CHECK_SEMANTIC_TYPE("IF", Token::TOK_IF);
  CHECK_SEMANTIC_TYPE("if", Token::TOK_IF);
  CHECK_SEMANTIC_TYPE("If", Token::TOK_IF);
  CHECK_SEMANTIC_TYPE("IS", Token::TOK_IS);
  CHECK_SEMANTIC_TYPE("is", Token::TOK_IS);
  CHECK_SEMANTIC_TYPE("Is", Token::TOK_IS);
  CHECK_SEMANTIC_TYPE("KEEP", Token::TOK_KEEP);
  CHECK_SEMANTIC_TYPE("keep", Token::TOK_KEEP);
  CHECK_SEMANTIC_TYPE("Keep", Token::TOK_KEEP);
  CHECK_SEMANTIC_TYPE("LEADING", Token::TOK_LEADING);
  CHECK_SEMANTIC_TYPE("leading", Token::TOK_LEADING);
  CHECK_SEMANTIC_TYPE("Leading", Token::TOK_LEADING);
  CHECK_SEMANTIC_TYPE("LEFT", Token::TOK_LEFT);
  CHECK_SEMANTIC_TYPE("left", Token::TOK_LEFT);
  CHECK_SEMANTIC_TYPE("Left", Token::TOK_LEFT);
  CHECK_SEMANTIC_TYPE("LENGTH", Token::TOK_LENGTH);
  CHECK_SEMANTIC_TYPE("length", Token::TOK_LENGTH);
  CHECK_SEMANTIC_TYPE("Length", Token::TOK_LENGTH);
  CHECK_SEMANTIC_TYPE("LET", Token::TOK_LET);
  CHECK_SEMANTIC_TYPE("let", Token::TOK_LET);
  CHECK_SEMANTIC_TYPE("Let", Token::TOK_LET);
  CHECK_SEMANTIC_TYPE("LIKE", Token::TOK_LIKE);
  CHECK_SEMANTIC_TYPE("like", Token::TOK_LIKE);
  CHECK_SEMANTIC_TYPE("Like", Token::TOK_LIKE);
  CHECK_SEMANTIC_TYPE("LIKE_REGEX", Token::TOK_LIKE_REGEX);
  CHECK_SEMANTIC_TYPE("like_regex", Token::TOK_LIKE_REGEX);
  CHECK_SEMANTIC_TYPE("Like_Regex", Token::TOK_LIKE_REGEX);
  CHECK_SEMANTIC_TYPE("LIMIT", Token::TOK_LIMIT);
  CHECK_SEMANTIC_TYPE("limit", Token::TOK_LIMIT);
  CHECK_SEMANTIC_TYPE("Limit", Token::TOK_LIMIT);
  CHECK_SEMANTIC_TYPE("LIST", Token::TOK_LIST);
  CHECK_SEMANTIC_TYPE("list", Token::TOK_LIST);
  CHECK_SEMANTIC_TYPE("List", Token::TOK_LIST);
  CHECK_SEMANTIC_TYPE("LN", Token::TOK_LN);
  CHECK_SEMANTIC_TYPE("ln", Token::TOK_LN);
  CHECK_SEMANTIC_TYPE("Ln", Token::TOK_LN);
  CHECK_SEMANTIC_TYPE("LOCALDATETIME", Token::TOK_LOCALDATETIME);
  CHECK_SEMANTIC_TYPE("localdatetime", Token::TOK_LOCALDATETIME);
  CHECK_SEMANTIC_TYPE("LocalDateTime", Token::TOK_LOCALDATETIME);
  CHECK_SEMANTIC_TYPE("LOCALTIME", Token::TOK_LOCALTIME);
  CHECK_SEMANTIC_TYPE("localtime", Token::TOK_LOCALTIME);
  CHECK_SEMANTIC_TYPE("LocalTime", Token::TOK_LOCALTIME);
  CHECK_SEMANTIC_TYPE("LOCALTIMESTAMP", Token::TOK_LOCALTIMESTAMP);
  CHECK_SEMANTIC_TYPE("localtimestamp", Token::TOK_LOCALTIMESTAMP);
  CHECK_SEMANTIC_TYPE("LocalTimeStamp", Token::TOK_LOCALTIMESTAMP);
  CHECK_SEMANTIC_TYPE("LOG", Token::TOK_LOG);
  CHECK_SEMANTIC_TYPE("log", Token::TOK_LOG);
  CHECK_SEMANTIC_TYPE("Log", Token::TOK_LOG);
  CHECK_SEMANTIC_TYPE("LOG10", Token::TOK_LOG10);
  CHECK_SEMANTIC_TYPE("log10", Token::TOK_LOG10);
  CHECK_SEMANTIC_TYPE("Log10", Token::TOK_LOG10);
  CHECK_SEMANTIC_TYPE("LOWER", Token::TOK_LOWER);
  CHECK_SEMANTIC_TYPE("lower", Token::TOK_LOWER);
  CHECK_SEMANTIC_TYPE("Lower", Token::TOK_LOWER);
  CHECK_SEMANTIC_TYPE("MANDATORY", Token::TOK_MANDATORY);
  CHECK_SEMANTIC_TYPE("mandatory", Token::TOK_MANDATORY);
  CHECK_SEMANTIC_TYPE("Mandatory", Token::TOK_MANDATORY);
  CHECK_SEMANTIC_TYPE("MAP", Token::TOK_MAP);
  CHECK_SEMANTIC_TYPE("map", Token::TOK_MAP);
  CHECK_SEMANTIC_TYPE("Map", Token::TOK_MAP);
  CHECK_SEMANTIC_TYPE("MATCH", Token::TOK_MATCH);
  CHECK_SEMANTIC_TYPE("match", Token::TOK_MATCH);
  CHECK_SEMANTIC_TYPE("Match", Token::TOK_MATCH);
  CHECK_SEMANTIC_TYPE("MERGE", Token::TOK_MERGE);
  CHECK_SEMANTIC_TYPE("merge", Token::TOK_MERGE);
  CHECK_SEMANTIC_TYPE("Merge", Token::TOK_MERGE);
  CHECK_SEMANTIC_TYPE("MAX", Token::TOK_MAX);
  CHECK_SEMANTIC_TYPE("max", Token::TOK_MAX);
  CHECK_SEMANTIC_TYPE("Max", Token::TOK_MAX);
  CHECK_SEMANTIC_TYPE("MIN", Token::TOK_MIN);
  CHECK_SEMANTIC_TYPE("min", Token::TOK_MIN);
  CHECK_SEMANTIC_TYPE("Min", Token::TOK_MIN);
  CHECK_SEMANTIC_TYPE("MINUTE", Token::TOK_MINUTE);
  CHECK_SEMANTIC_TYPE("minute", Token::TOK_MINUTE);
  CHECK_SEMANTIC_TYPE("Minute", Token::TOK_MINUTE);
  CHECK_SEMANTIC_TYPE("MOD", Token::TOK_MOD);
  CHECK_SEMANTIC_TYPE("mod", Token::TOK_MOD);
  CHECK_SEMANTIC_TYPE("Mod", Token::TOK_MOD);
  CHECK_SEMANTIC_TYPE("MONTH", Token::TOK_MONTH);
  CHECK_SEMANTIC_TYPE("month", Token::TOK_MONTH);
  CHECK_SEMANTIC_TYPE("Month", Token::TOK_MONTH);
  CHECK_SEMANTIC_TYPE("MULTI", Token::TOK_MULTI);
  CHECK_SEMANTIC_TYPE("multi", Token::TOK_MULTI);
  CHECK_SEMANTIC_TYPE("MulTi", Token::TOK_MULTI);
  CHECK_SEMANTIC_TYPE("MULTIPLE", Token::TOK_MULTIPLE);
  CHECK_SEMANTIC_TYPE("multiple", Token::TOK_MULTIPLE);
  CHECK_SEMANTIC_TYPE("MultiPLE", Token::TOK_MULTIPLE);
  CHECK_SEMANTIC_TYPE("MULTISET", Token::TOK_MULTISET);
  CHECK_SEMANTIC_TYPE("multiset", Token::TOK_MULTISET);
  CHECK_SEMANTIC_TYPE("Multiset", Token::TOK_MULTISET);
  CHECK_SEMANTIC_TYPE("NEW", Token::TOK_NEW);
  CHECK_SEMANTIC_TYPE("new", Token::TOK_NEW);
  CHECK_SEMANTIC_TYPE("New", Token::TOK_NEW);
  CHECK_SEMANTIC_TYPE("NOT", Token::TOK_NOT);
  CHECK_SEMANTIC_TYPE("not", Token::TOK_NOT);
  CHECK_SEMANTIC_TYPE("Not", Token::TOK_NOT);
  CHECK_SEMANTIC_TYPE("NORMALIZE", Token::TOK_NORMALIZE);
  CHECK_SEMANTIC_TYPE("normalize", Token::TOK_NORMALIZE);
  CHECK_SEMANTIC_TYPE("NormaLIZE", Token::TOK_NORMALIZE);
  CHECK_SEMANTIC_TYPE("NOTHING", Token::TOK_NOTHING);
  CHECK_SEMANTIC_TYPE("nothing", Token::TOK_NOTHING);
  CHECK_SEMANTIC_TYPE("Nothing", Token::TOK_NOTHING);
  CHECK_SEMANTIC_TYPE("NULL", Token::TOK_NULL);
  CHECK_SEMANTIC_TYPE("null", Token::TOK_NULL);
  CHECK_SEMANTIC_TYPE("Null", Token::TOK_NULL);
  CHECK_SEMANTIC_TYPE("NULLS", Token::TOK_NULLS);
  CHECK_SEMANTIC_TYPE("nulls", Token::TOK_NULLS);
  CHECK_SEMANTIC_TYPE("NullS", Token::TOK_NULLS);
  CHECK_SEMANTIC_TYPE("NULLIF", Token::TOK_NULLIF);
  CHECK_SEMANTIC_TYPE("nullif", Token::TOK_NULLIF);
  CHECK_SEMANTIC_TYPE("NullIf", Token::TOK_NULLIF);
  CHECK_SEMANTIC_TYPE("NUMERIC", Token::TOK_NUMERIC);
  CHECK_SEMANTIC_TYPE("numeric", Token::TOK_NUMERIC);
  CHECK_SEMANTIC_TYPE("Numeric", Token::TOK_NUMERIC);
  CHECK_SEMANTIC_TYPE("OCCURRENCES_REGEX", Token::TOK_OCCURRENCES_REGEX);
  CHECK_SEMANTIC_TYPE("occurrences_regex", Token::TOK_OCCURRENCES_REGEX);
  CHECK_SEMANTIC_TYPE("Occurrences_Regex", Token::TOK_OCCURRENCES_REGEX);
  CHECK_SEMANTIC_TYPE("OCTET_LENGTH", Token::TOK_OCTET_LENGTH);
  CHECK_SEMANTIC_TYPE("octet_length", Token::TOK_OCTET_LENGTH);
  CHECK_SEMANTIC_TYPE("Octet_Length", Token::TOK_OCTET_LENGTH);
  CHECK_SEMANTIC_TYPE("OF", Token::TOK_OF);
  CHECK_SEMANTIC_TYPE("of", Token::TOK_OF);
  CHECK_SEMANTIC_TYPE("Of", Token::TOK_OF);
  CHECK_SEMANTIC_TYPE("OFFSET", Token::TOK_OFFSET);
  CHECK_SEMANTIC_TYPE("offset", Token::TOK_OFFSET);
  CHECK_SEMANTIC_TYPE("OfFSet", Token::TOK_OFFSET);
  CHECK_SEMANTIC_TYPE("ON", Token::TOK_ON);
  CHECK_SEMANTIC_TYPE("on", Token::TOK_ON);
  CHECK_SEMANTIC_TYPE("On", Token::TOK_ON);
  CHECK_SEMANTIC_TYPE("OPTIONAL", Token::TOK_OPTIONAL);
  CHECK_SEMANTIC_TYPE("optional", Token::TOK_OPTIONAL);
  CHECK_SEMANTIC_TYPE("Optional", Token::TOK_OPTIONAL);
  CHECK_SEMANTIC_TYPE("OR", Token::TOK_OR);
  CHECK_SEMANTIC_TYPE("or", Token::TOK_OR);
  CHECK_SEMANTIC_TYPE("Or", Token::TOK_OR);
  CHECK_SEMANTIC_TYPE("ORDER", Token::TOK_ORDER);
  CHECK_SEMANTIC_TYPE("order", Token::TOK_ORDER);
  CHECK_SEMANTIC_TYPE("OrDEr", Token::TOK_ORDER);
  CHECK_SEMANTIC_TYPE("ORDERED", Token::TOK_ORDERED);
  CHECK_SEMANTIC_TYPE("ordered", Token::TOK_ORDERED);
  CHECK_SEMANTIC_TYPE("OrderED", Token::TOK_ORDERED);
  CHECK_SEMANTIC_TYPE("OTHERWISE", Token::TOK_OTHERWISE);
  CHECK_SEMANTIC_TYPE("otherwise", Token::TOK_OTHERWISE);
  CHECK_SEMANTIC_TYPE("OtherWise", Token::TOK_OTHERWISE);
  CHECK_SEMANTIC_TYPE("PARAMETER", Token::TOK_PARAMETER);
  CHECK_SEMANTIC_TYPE("parameter", Token::TOK_PARAMETER);
  CHECK_SEMANTIC_TYPE("ParameTER", Token::TOK_PARAMETER);
  CHECK_SEMANTIC_TYPE("PATH", Token::TOK_PATH);
  CHECK_SEMANTIC_TYPE("path", Token::TOK_PATH);
  CHECK_SEMANTIC_TYPE("Path", Token::TOK_PATH);
  CHECK_SEMANTIC_TYPE("PATHS", Token::TOK_PATHS);
  CHECK_SEMANTIC_TYPE("paths", Token::TOK_PATHS);
  CHECK_SEMANTIC_TYPE("PathS", Token::TOK_PATHS);
  CHECK_SEMANTIC_TYPE("PARTITION", Token::TOK_PARTITION);
  CHECK_SEMANTIC_TYPE("partition", Token::TOK_PARTITION);
  CHECK_SEMANTIC_TYPE("Partition", Token::TOK_PARTITION);
  CHECK_SEMANTIC_TYPE("POSITION_REGEX", Token::TOK_POSITION_REGEX);
  CHECK_SEMANTIC_TYPE("position_regex", Token::TOK_POSITION_REGEX);
  CHECK_SEMANTIC_TYPE("Position_Regex", Token::TOK_POSITION_REGEX);
  CHECK_SEMANTIC_TYPE("POWER", Token::TOK_POWER);
  CHECK_SEMANTIC_TYPE("power", Token::TOK_POWER);
  CHECK_SEMANTIC_TYPE("Power", Token::TOK_POWER);
  CHECK_SEMANTIC_TYPE("PRECISION", Token::TOK_PRECISION);
  CHECK_SEMANTIC_TYPE("precision", Token::TOK_PRECISION);
  CHECK_SEMANTIC_TYPE("Precision", Token::TOK_PRECISION);
  CHECK_SEMANTIC_TYPE("PROCEDURE", Token::TOK_PROCEDURE);
  CHECK_SEMANTIC_TYPE("procedure", Token::TOK_PROCEDURE);
  CHECK_SEMANTIC_TYPE("Procedure", Token::TOK_PROCEDURE);
  CHECK_SEMANTIC_TYPE("PROCEDURES", Token::TOK_PROCEDURES);
  CHECK_SEMANTIC_TYPE("procedures", Token::TOK_PROCEDURES);
  CHECK_SEMANTIC_TYPE("ProCedureS", Token::TOK_PROCEDURES);
  CHECK_SEMANTIC_TYPE("PRODUCT", Token::TOK_PRODUCT);
  CHECK_SEMANTIC_TYPE("product", Token::TOK_PRODUCT);
  CHECK_SEMANTIC_TYPE("Product", Token::TOK_PRODUCT);
  CHECK_SEMANTIC_TYPE("PROFILE", Token::TOK_PROFILE);
  CHECK_SEMANTIC_TYPE("profile", Token::TOK_PROFILE);
  CHECK_SEMANTIC_TYPE("Profile", Token::TOK_PROFILE);
  CHECK_SEMANTIC_TYPE("PROJECT", Token::TOK_PROJECT);
  CHECK_SEMANTIC_TYPE("project", Token::TOK_PROJECT);
  CHECK_SEMANTIC_TYPE("Project", Token::TOK_PROJECT);
  CHECK_SEMANTIC_TYPE("QUERIES", Token::TOK_QUERIES);
  CHECK_SEMANTIC_TYPE("queries", Token::TOK_QUERIES);
  CHECK_SEMANTIC_TYPE("QuerieS", Token::TOK_QUERIES);
  CHECK_SEMANTIC_TYPE("QUERY", Token::TOK_QUERY);
  CHECK_SEMANTIC_TYPE("query", Token::TOK_QUERY);
  CHECK_SEMANTIC_TYPE("Query", Token::TOK_QUERY);
  CHECK_SEMANTIC_TYPE("RADIANS", Token::TOK_RADIANS);
  CHECK_SEMANTIC_TYPE("radians", Token::TOK_RADIANS);
  CHECK_SEMANTIC_TYPE("Radians", Token::TOK_RADIANS);
  CHECK_SEMANTIC_TYPE("REAL", Token::TOK_REAL);
  CHECK_SEMANTIC_TYPE("real", Token::TOK_REAL);
  CHECK_SEMANTIC_TYPE("ReaL", Token::TOK_REAL);
  CHECK_SEMANTIC_TYPE("RECORD", Token::TOK_RECORD);
  CHECK_SEMANTIC_TYPE("record", Token::TOK_RECORD);
  CHECK_SEMANTIC_TYPE("ReCord", Token::TOK_RECORD);
  CHECK_SEMANTIC_TYPE("RECORDS", Token::TOK_RECORDS);
  CHECK_SEMANTIC_TYPE("records", Token::TOK_RECORDS);
  CHECK_SEMANTIC_TYPE("Records", Token::TOK_RECORDS);
  CHECK_SEMANTIC_TYPE("REFERENCE", Token::TOK_REFERENCE);
  CHECK_SEMANTIC_TYPE("reference", Token::TOK_REFERENCE);
  CHECK_SEMANTIC_TYPE("ReferenCE", Token::TOK_REFERENCE);
  CHECK_SEMANTIC_TYPE("REMOVE", Token::TOK_REMOVE);
  CHECK_SEMANTIC_TYPE("remove", Token::TOK_REMOVE);
  CHECK_SEMANTIC_TYPE("RENAME", Token::TOK_RENAME);
  CHECK_SEMANTIC_TYPE("rename", Token::TOK_RENAME);
  CHECK_SEMANTIC_TYPE("ReNAME", Token::TOK_RENAME);
  CHECK_SEMANTIC_TYPE("REPLACE", Token::TOK_REPLACE);
  CHECK_SEMANTIC_TYPE("replace", Token::TOK_REPLACE);
  CHECK_SEMANTIC_TYPE("Replace", Token::TOK_REPLACE);
  CHECK_SEMANTIC_TYPE("REQUIRE", Token::TOK_REQUIRE);
  CHECK_SEMANTIC_TYPE("require", Token::TOK_REQUIRE);
  CHECK_SEMANTIC_TYPE("RequiRE", Token::TOK_REQUIRE);
  CHECK_SEMANTIC_TYPE("RESET", Token::TOK_RESET);
  CHECK_SEMANTIC_TYPE("reset", Token::TOK_RESET);
  CHECK_SEMANTIC_TYPE("Reset", Token::TOK_RESET);
  CHECK_SEMANTIC_TYPE("RESULT", Token::TOK_RESULT);
  CHECK_SEMANTIC_TYPE("result", Token::TOK_RESULT);
  CHECK_SEMANTIC_TYPE("Result", Token::TOK_RESULT);
  CHECK_SEMANTIC_TYPE("RETURN", Token::TOK_RETURN);
  CHECK_SEMANTIC_TYPE("return", Token::TOK_RETURN);
  CHECK_SEMANTIC_TYPE("Return", Token::TOK_RETURN);
  CHECK_SEMANTIC_TYPE("REVOKE", Token::TOK_REVOKE);
  CHECK_SEMANTIC_TYPE("revoke", Token::TOK_REVOKE);
  CHECK_SEMANTIC_TYPE("Revoke", Token::TOK_REVOKE);
  CHECK_SEMANTIC_TYPE("RIGHT", Token::TOK_RIGHT);
  CHECK_SEMANTIC_TYPE("right", Token::TOK_RIGHT);
  CHECK_SEMANTIC_TYPE("Right", Token::TOK_RIGHT);
  CHECK_SEMANTIC_TYPE("ROLLBACK", Token::TOK_ROLLBACK);
  CHECK_SEMANTIC_TYPE("rollback", Token::TOK_ROLLBACK);
  CHECK_SEMANTIC_TYPE("RollBack", Token::TOK_ROLLBACK);
  CHECK_SEMANTIC_TYPE("SAME", Token::TOK_SAME);
  CHECK_SEMANTIC_TYPE("same", Token::TOK_SAME);
  CHECK_SEMANTIC_TYPE("Same", Token::TOK_SAME);
  CHECK_SEMANTIC_TYPE("SCALAR", Token::TOK_SCALAR);
  CHECK_SEMANTIC_TYPE("scalar", Token::TOK_SCALAR);
  CHECK_SEMANTIC_TYPE("ScalAR", Token::TOK_SCALAR);
  CHECK_SEMANTIC_TYPE("SCHEMA", Token::TOK_SCHEMA);
  CHECK_SEMANTIC_TYPE("schema", Token::TOK_SCHEMA);
  CHECK_SEMANTIC_TYPE("ScheMA", Token::TOK_SCHEMA);
  CHECK_SEMANTIC_TYPE("SCHEMAS", Token::TOK_SCHEMAS);
  CHECK_SEMANTIC_TYPE("schemas", Token::TOK_SCHEMAS);
  CHECK_SEMANTIC_TYPE("Schemas", Token::TOK_SCHEMAS);
  CHECK_SEMANTIC_TYPE("SCHEMATA", Token::TOK_SCHEMATA);
  CHECK_SEMANTIC_TYPE("schemata", Token::TOK_SCHEMATA);
  CHECK_SEMANTIC_TYPE("SchemaTA", Token::TOK_SCHEMATA);
  CHECK_SEMANTIC_TYPE("SECOND", Token::TOK_SECOND);
  CHECK_SEMANTIC_TYPE("second", Token::TOK_SECOND);
  CHECK_SEMANTIC_TYPE("SecONd", Token::TOK_SECOND);
  CHECK_SEMANTIC_TYPE("SELECT", Token::TOK_SELECT);
  CHECK_SEMANTIC_TYPE("select", Token::TOK_SELECT);
  CHECK_SEMANTIC_TYPE("SelECt", Token::TOK_SELECT);
  CHECK_SEMANTIC_TYPE("SESSION", Token::TOK_SESSION);
  CHECK_SEMANTIC_TYPE("session", Token::TOK_SESSION);
  CHECK_SEMANTIC_TYPE("SessIOn", Token::TOK_SESSION);
  CHECK_SEMANTIC_TYPE("SET", Token::TOK_SET);
  CHECK_SEMANTIC_TYPE("set", Token::TOK_SET);
  CHECK_SEMANTIC_TYPE("Set", Token::TOK_SET);
  CHECK_SEMANTIC_TYPE("SKIP", Token::TOK_SKIP);
  CHECK_SEMANTIC_TYPE("skip", Token::TOK_SKIP);
  CHECK_SEMANTIC_TYPE("SkiP", Token::TOK_SKIP);
  CHECK_SEMANTIC_TYPE("SIGNED", Token::TOK_SIGNED);
  CHECK_SEMANTIC_TYPE("signed", Token::TOK_SIGNED);
  CHECK_SEMANTIC_TYPE("SigneD", Token::TOK_SIGNED);
  CHECK_SEMANTIC_TYPE("SIN", Token::TOK_SIN);
  CHECK_SEMANTIC_TYPE("sin", Token::TOK_SIN);
  CHECK_SEMANTIC_TYPE("Sin", Token::TOK_SIN);
  CHECK_SEMANTIC_TYPE("SINGLE", Token::TOK_SINGLE);
  CHECK_SEMANTIC_TYPE("single", Token::TOK_SINGLE);
  CHECK_SEMANTIC_TYPE("SingLE", Token::TOK_SINGLE);
  CHECK_SEMANTIC_TYPE("SINH", Token::TOK_SINH);
  CHECK_SEMANTIC_TYPE("sinh", Token::TOK_SINH);
  CHECK_SEMANTIC_TYPE("SinH", Token::TOK_SINH);
  CHECK_SEMANTIC_TYPE("SMALLINT", Token::TOK_SMALLINT);
  CHECK_SEMANTIC_TYPE("smallint", Token::TOK_SMALLINT);
  CHECK_SEMANTIC_TYPE("SmallInt", Token::TOK_SMALLINT);
  CHECK_SEMANTIC_TYPE("SQRT", Token::TOK_SQRT);
  CHECK_SEMANTIC_TYPE("sqrt", Token::TOK_SQRT);
  CHECK_SEMANTIC_TYPE("SqrT", Token::TOK_SQRT);
  CHECK_SEMANTIC_TYPE("START", Token::TOK_START);
  CHECK_SEMANTIC_TYPE("start", Token::TOK_START);
  CHECK_SEMANTIC_TYPE("Start", Token::TOK_START);
  CHECK_SEMANTIC_TYPE("STARTS", Token::TOK_STARTS);
  CHECK_SEMANTIC_TYPE("starts", Token::TOK_STARTS);
  CHECK_SEMANTIC_TYPE("Starts", Token::TOK_STARTS);
  CHECK_SEMANTIC_TYPE("STRING", Token::TOK_STRING);
  CHECK_SEMANTIC_TYPE("string", Token::TOK_STRING);
  CHECK_SEMANTIC_TYPE("StriNG", Token::TOK_STRING);
  CHECK_SEMANTIC_TYPE("SUBSTRING", Token::TOK_SUBSTRING);
  CHECK_SEMANTIC_TYPE("substring", Token::TOK_SUBSTRING);
  CHECK_SEMANTIC_TYPE("SubString", Token::TOK_SUBSTRING);
  CHECK_SEMANTIC_TYPE("SUBSTRING_REGEX", Token::TOK_SUBSTRING_REGEX);
  CHECK_SEMANTIC_TYPE("substring_regex", Token::TOK_SUBSTRING_REGEX);
  CHECK_SEMANTIC_TYPE("SubString_Regex", Token::TOK_SUBSTRING_REGEX);
  CHECK_SEMANTIC_TYPE("SUM", Token::TOK_SUM);
  CHECK_SEMANTIC_TYPE("sum", Token::TOK_SUM);
  CHECK_SEMANTIC_TYPE("Sum", Token::TOK_SUM);
  CHECK_SEMANTIC_TYPE("TAN", Token::TOK_TAN);
  CHECK_SEMANTIC_TYPE("tan", Token::TOK_TAN);
  CHECK_SEMANTIC_TYPE("Tan", Token::TOK_TAN);
  CHECK_SEMANTIC_TYPE("TANH", Token::TOK_TANH);
  CHECK_SEMANTIC_TYPE("tanh", Token::TOK_TANH);
  CHECK_SEMANTIC_TYPE("TanH", Token::TOK_TANH);
  CHECK_SEMANTIC_TYPE("THEN", Token::TOK_THEN);
  CHECK_SEMANTIC_TYPE("then", Token::TOK_THEN);
  CHECK_SEMANTIC_TYPE("Then", Token::TOK_THEN);
  CHECK_SEMANTIC_TYPE("TIME", Token::TOK_TIME);
  CHECK_SEMANTIC_TYPE("time", Token::TOK_TIME);
  CHECK_SEMANTIC_TYPE("Time", Token::TOK_TIME);
  CHECK_SEMANTIC_TYPE("TIMESTAMP", Token::TOK_TIMESTAMP);
  CHECK_SEMANTIC_TYPE("timestamp", Token::TOK_TIMESTAMP);
  CHECK_SEMANTIC_TYPE("Timestamp", Token::TOK_TIMESTAMP);
  CHECK_SEMANTIC_TYPE("TRAILING", Token::TOK_TRAILING);
  CHECK_SEMANTIC_TYPE("trailing", Token::TOK_TRAILING);
  CHECK_SEMANTIC_TYPE("TrailINg", Token::TOK_TRAILING);
  CHECK_SEMANTIC_TYPE("TRANSLATE_REGEX", Token::TOK_TRANSLATE_REGEX);
  CHECK_SEMANTIC_TYPE("translate_regex", Token::TOK_TRANSLATE_REGEX);
  CHECK_SEMANTIC_TYPE("Translate_Regex", Token::TOK_TRANSLATE_REGEX);
  CHECK_SEMANTIC_TYPE("TRIM", Token::TOK_TRIM);
  CHECK_SEMANTIC_TYPE("trim", Token::TOK_TRIM);
  CHECK_SEMANTIC_TYPE("Trim", Token::TOK_TRIM);
  CHECK_SEMANTIC_TYPE("TRUE", Token::TOK_TRUE);
  CHECK_SEMANTIC_TYPE("true", Token::TOK_TRUE);
  CHECK_SEMANTIC_TYPE("tRue", Token::TOK_TRUE);
  CHECK_SEMANTIC_TYPE("TRUNCATE", Token::TOK_TRUNCATE);
  CHECK_SEMANTIC_TYPE("truncate", Token::TOK_TRUNCATE);
  CHECK_SEMANTIC_TYPE("Truncate", Token::TOK_TRUNCATE);
  CHECK_SEMANTIC_TYPE("UINT", Token::TOK_UINT);
  CHECK_SEMANTIC_TYPE("uint", Token::TOK_UINT);
  CHECK_SEMANTIC_TYPE("UInt", Token::TOK_UINT);
  CHECK_SEMANTIC_TYPE("UINT8", Token::TOK_UINT8);
  CHECK_SEMANTIC_TYPE("uint8", Token::TOK_UINT8);
  CHECK_SEMANTIC_TYPE("UInt8", Token::TOK_UINT8);
  CHECK_SEMANTIC_TYPE("UINT16", Token::TOK_UINT16);
  CHECK_SEMANTIC_TYPE("uint16", Token::TOK_UINT16);
  CHECK_SEMANTIC_TYPE("UInt16", Token::TOK_UINT16);
  CHECK_SEMANTIC_TYPE("UINT32", Token::TOK_UINT32);
  CHECK_SEMANTIC_TYPE("uint32", Token::TOK_UINT32);
  CHECK_SEMANTIC_TYPE("UInt32", Token::TOK_UINT32);
  CHECK_SEMANTIC_TYPE("UINT64", Token::TOK_UINT64);
  CHECK_SEMANTIC_TYPE("uint64", Token::TOK_UINT64);
  CHECK_SEMANTIC_TYPE("UInt64", Token::TOK_UINT64);
  CHECK_SEMANTIC_TYPE("UINT128", Token::TOK_UINT128);
  CHECK_SEMANTIC_TYPE("uint128", Token::TOK_UINT128);
  CHECK_SEMANTIC_TYPE("UInt128", Token::TOK_UINT128);
  CHECK_SEMANTIC_TYPE("UINT256", Token::TOK_UINT256);
  CHECK_SEMANTIC_TYPE("uint256", Token::TOK_UINT256);
  CHECK_SEMANTIC_TYPE("UInt256", Token::TOK_UINT256);
  CHECK_SEMANTIC_TYPE("UNION", Token::TOK_UNION);
  CHECK_SEMANTIC_TYPE("union", Token::TOK_UNION);
  CHECK_SEMANTIC_TYPE("Union", Token::TOK_UNION);
  CHECK_SEMANTIC_TYPE("UNIT", Token::TOK_UNIT);
  CHECK_SEMANTIC_TYPE("unit", Token::TOK_UNIT);
  CHECK_SEMANTIC_TYPE("Unit", Token::TOK_UNIT);
  CHECK_SEMANTIC_TYPE("UNIT_BINDING_TABLE", Token::TOK_UNIT_BINDING_TABLE);
  CHECK_SEMANTIC_TYPE("unit_binding_table", Token::TOK_UNIT_BINDING_TABLE);
  CHECK_SEMANTIC_TYPE("Unit_Binding_Table", Token::TOK_UNIT_BINDING_TABLE);
  CHECK_SEMANTIC_TYPE("UNIT_TABLE", Token::TOK_UNIT_TABLE);
  CHECK_SEMANTIC_TYPE("unit_table", Token::TOK_UNIT_TABLE);
  CHECK_SEMANTIC_TYPE("Unit_Table", Token::TOK_UNIT_TABLE);
  CHECK_SEMANTIC_TYPE("UNIQUE", Token::TOK_UNIQUE);
  CHECK_SEMANTIC_TYPE("unique", Token::TOK_UNIQUE);
  CHECK_SEMANTIC_TYPE("UNiqUE", Token::TOK_UNIQUE);
  CHECK_SEMANTIC_TYPE("UNNEST", Token::TOK_UNNEST);
  CHECK_SEMANTIC_TYPE("unnest", Token::TOK_UNNEST);
  CHECK_SEMANTIC_TYPE("UnNEST", Token::TOK_UNNEST);
  CHECK_SEMANTIC_TYPE("UNKNOWN", Token::TOK_UNKNOWN);
  CHECK_SEMANTIC_TYPE("unknown", Token::TOK_UNKNOWN);
  CHECK_SEMANTIC_TYPE("uNKNown", Token::TOK_UNKNOWN);
  CHECK_SEMANTIC_TYPE("UNSIGNED", Token::TOK_UNSIGNED);
  CHECK_SEMANTIC_TYPE("unsigned", Token::TOK_UNSIGNED);
  CHECK_SEMANTIC_TYPE("uNsigned", Token::TOK_UNSIGNED);
  CHECK_SEMANTIC_TYPE("UNWIND", Token::TOK_UNWIND);
  CHECK_SEMANTIC_TYPE("unwind", Token::TOK_UNWIND);
  CHECK_SEMANTIC_TYPE("uNWind", Token::TOK_UNWIND);
  CHECK_SEMANTIC_TYPE("UPPER", Token::TOK_UPPER);
  CHECK_SEMANTIC_TYPE("upper", Token::TOK_UPPER);
  CHECK_SEMANTIC_TYPE("UppER", Token::TOK_UPPER);
  CHECK_SEMANTIC_TYPE("USE", Token::TOK_USE);
  CHECK_SEMANTIC_TYPE("use", Token::TOK_USE);
  CHECK_SEMANTIC_TYPE("uSe", Token::TOK_USE);
  CHECK_SEMANTIC_TYPE("VALUE", Token::TOK_VALUE);
  CHECK_SEMANTIC_TYPE("value", Token::TOK_VALUE);
  CHECK_SEMANTIC_TYPE("vaLUe", Token::TOK_VALUE);
  CHECK_SEMANTIC_TYPE("VALUES", Token::TOK_VALUES);
  CHECK_SEMANTIC_TYPE("values", Token::TOK_VALUES);
  CHECK_SEMANTIC_TYPE("ValUES", Token::TOK_VALUES);
  CHECK_SEMANTIC_TYPE("VARBINARY", Token::TOK_VARBINARY);
  CHECK_SEMANTIC_TYPE("varbinary", Token::TOK_VARBINARY);
  CHECK_SEMANTIC_TYPE("VARbinARY", Token::TOK_VARBINARY);
  CHECK_SEMANTIC_TYPE("VARCHAR", Token::TOK_VARCHAR);
  CHECK_SEMANTIC_TYPE("varchar", Token::TOK_VARCHAR);
  CHECK_SEMANTIC_TYPE("VarChAR", Token::TOK_VARCHAR);
  CHECK_SEMANTIC_TYPE("WHEN", Token::TOK_WHEN);
  CHECK_SEMANTIC_TYPE("when", Token::TOK_WHEN);
  CHECK_SEMANTIC_TYPE("WheN", Token::TOK_WHEN);
  CHECK_SEMANTIC_TYPE("WHERE", Token::TOK_WHERE);
  CHECK_SEMANTIC_TYPE("where", Token::TOK_WHERE);
  CHECK_SEMANTIC_TYPE("WHeRe", Token::TOK_WHERE);
  CHECK_SEMANTIC_TYPE("WITH", Token::TOK_WITH);
  CHECK_SEMANTIC_TYPE("with", Token::TOK_WITH);
  CHECK_SEMANTIC_TYPE("WitH", Token::TOK_WITH);
  CHECK_SEMANTIC_TYPE("WITHOUT", Token::TOK_WITHOUT);
  CHECK_SEMANTIC_TYPE("without", Token::TOK_WITHOUT);
  CHECK_SEMANTIC_TYPE("WIThoUT", Token::TOK_WITHOUT);
  CHECK_SEMANTIC_TYPE("XOR", Token::TOK_XOR);
  CHECK_SEMANTIC_TYPE("xor", Token::TOK_XOR);
  CHECK_SEMANTIC_TYPE("Xor", Token::TOK_XOR);
  CHECK_SEMANTIC_TYPE("YEAR", Token::TOK_YEAR);
  CHECK_SEMANTIC_TYPE("year", Token::TOK_YEAR);
  CHECK_SEMANTIC_TYPE("YeaR", Token::TOK_YEAR);
  CHECK_SEMANTIC_TYPE("YIELD", Token::TOK_YIELD);
  CHECK_SEMANTIC_TYPE("yield", Token::TOK_YIELD);
  CHECK_SEMANTIC_TYPE("YieLD", Token::TOK_YIELD);
  CHECK_SEMANTIC_TYPE("ZERO", Token::TOK_ZERO);
  CHECK_SEMANTIC_TYPE("zero", Token::TOK_ZERO);
  CHECK_SEMANTIC_TYPE("ZERo", Token::TOK_ZERO);
}

TEST_F(ScannerTest, CaseInsensitiveNonReservedKeywords) {
  CHECK_SEMANTIC_VALUE("ACYCLIC", Token::TOK_ACYCLIC, "ACYCLIC");
  CHECK_SEMANTIC_VALUE("acyclic", Token::TOK_ACYCLIC, "acyclic");
  CHECK_SEMANTIC_VALUE("aCYClic", Token::TOK_ACYCLIC, "aCYClic");
  CHECK_SEMANTIC_VALUE("BINDING", Token::TOK_BINDING, "BINDING");
  CHECK_SEMANTIC_VALUE("binding", Token::TOK_BINDING, "binding");
  CHECK_SEMANTIC_VALUE("bINDING", Token::TOK_BINDING, "bINDING");
  CHECK_SEMANTIC_VALUE("CLASS_ORIGIN", Token::TOK_CLASS_ORIGIN, "CLASS_ORIGIN");
  CHECK_SEMANTIC_VALUE("class_origin", Token::TOK_CLASS_ORIGIN, "class_origin");
  CHECK_SEMANTIC_VALUE("cLASS_oRIGIN", Token::TOK_CLASS_ORIGIN, "cLASS_oRIGIN");
  CHECK_SEMANTIC_VALUE("COMMAND_FUNCTION", Token::TOK_COMMAND_FUNCTION, "COMMAND_FUNCTION");
  CHECK_SEMANTIC_VALUE("command_function", Token::TOK_COMMAND_FUNCTION, "command_function");
  CHECK_SEMANTIC_VALUE("cOMMAND_FUNCTION", Token::TOK_COMMAND_FUNCTION, "cOMMAND_FUNCTION");
  CHECK_SEMANTIC_VALUE(
      "COMMAND_FUNCTION_CODE", Token::TOK_COMMAND_FUNCTION_CODE, "COMMAND_FUNCTION_CODE");
  CHECK_SEMANTIC_VALUE(
      "command_function_code", Token::TOK_COMMAND_FUNCTION_CODE, "command_function_code");
  CHECK_SEMANTIC_VALUE(
      "cOMMAND_FUNCTION_code", Token::TOK_COMMAND_FUNCTION_CODE, "cOMMAND_FUNCTION_code");
  CHECK_SEMANTIC_VALUE("CONDITION_NUMBER", Token::TOK_CONDITION_NUMBER, "CONDITION_NUMBER");
  CHECK_SEMANTIC_VALUE("condition_number", Token::TOK_CONDITION_NUMBER, "condition_number");
  CHECK_SEMANTIC_VALUE("cONDITION_NumBER", Token::TOK_CONDITION_NUMBER, "cONDITION_NumBER");
  CHECK_SEMANTIC_VALUE("CONNECTING", Token::TOK_CONNECTING, "CONNECTING");
  CHECK_SEMANTIC_VALUE("connecting", Token::TOK_CONNECTING, "connecting");
  CHECK_SEMANTIC_VALUE("cONNECTING", Token::TOK_CONNECTING, "cONNECTING");
  CHECK_SEMANTIC_VALUE("DESTINATION", Token::TOK_DESTINATION, "DESTINATION");
  CHECK_SEMANTIC_VALUE("destination", Token::TOK_DESTINATION, "destination");
  CHECK_SEMANTIC_VALUE("dESTINAtion", Token::TOK_DESTINATION, "dESTINAtion");
  CHECK_SEMANTIC_VALUE("DIRECTED", Token::TOK_DIRECTED, "DIRECTED");
  CHECK_SEMANTIC_VALUE("directed", Token::TOK_DIRECTED, "directed");
  CHECK_SEMANTIC_VALUE("Directed", Token::TOK_DIRECTED, "Directed");
  CHECK_SEMANTIC_VALUE("EDGE", Token::TOK_EDGE_SYNONYM, "EDGE");
  CHECK_SEMANTIC_VALUE("edge", Token::TOK_EDGE_SYNONYM, "edge");
  CHECK_SEMANTIC_VALUE("Edge", Token::TOK_EDGE_SYNONYM, "Edge");
  CHECK_SEMANTIC_VALUE("EDGES", Token::TOK_EDGES, "EDGES");
  CHECK_SEMANTIC_VALUE("edges", Token::TOK_EDGES, "edges");
  CHECK_SEMANTIC_VALUE("Edges", Token::TOK_EDGES, "Edges");
  CHECK_SEMANTIC_VALUE("FINAL", Token::TOK_FINAL, "FINAL");
  CHECK_SEMANTIC_VALUE("final", Token::TOK_FINAL, "final");
  CHECK_SEMANTIC_VALUE("FINal", Token::TOK_FINAL, "FINal");
  CHECK_SEMANTIC_VALUE("FIRST", Token::TOK_FIRST, "FIRST");
  CHECK_SEMANTIC_VALUE("first", Token::TOK_FIRST, "first");
  CHECK_SEMANTIC_VALUE("fIRST", Token::TOK_FIRST, "fIRST");
  CHECK_SEMANTIC_VALUE("GRAPH", Token::TOK_GRAPH_SYNONYM, "GRAPH");
  CHECK_SEMANTIC_VALUE("graph", Token::TOK_GRAPH_SYNONYM, "graph");
  CHECK_SEMANTIC_VALUE("GraPh", Token::TOK_GRAPH_SYNONYM, "GraPh");
  CHECK_SEMANTIC_VALUE("GRAPHS", Token::TOK_GRAPHS, "GRAPHS");
  CHECK_SEMANTIC_VALUE("graphs", Token::TOK_GRAPHS, "graphs");
  CHECK_SEMANTIC_VALUE("GraPhs", Token::TOK_GRAPHS, "GraPhs");
  CHECK_SEMANTIC_VALUE("GROUPS", Token::TOK_GROUPS, "GROUPS");
  CHECK_SEMANTIC_VALUE("groups", Token::TOK_GROUPS, "groups");
  CHECK_SEMANTIC_VALUE("Groups", Token::TOK_GROUPS, "Groups");
  CHECK_SEMANTIC_VALUE("INDEX", Token::TOK_INDEX, "INDEX");
  CHECK_SEMANTIC_VALUE("index", Token::TOK_INDEX, "index");
  CHECK_SEMANTIC_VALUE("iNDEX", Token::TOK_INDEX, "iNDEX");
  CHECK_SEMANTIC_VALUE("LAST", Token::TOK_LAST, "LAST");
  CHECK_SEMANTIC_VALUE("last", Token::TOK_LAST, "last");
  CHECK_SEMANTIC_VALUE("lAST", Token::TOK_LAST, "lAST");
  CHECK_SEMANTIC_VALUE("LABEL", Token::TOK_LABEL, "LABEL");
  CHECK_SEMANTIC_VALUE("label", Token::TOK_LABEL, "label");
  CHECK_SEMANTIC_VALUE("lABEL", Token::TOK_LABEL, "lABEL");
  CHECK_SEMANTIC_VALUE("LABELED", Token::TOK_LABELED, "LABELED");
  CHECK_SEMANTIC_VALUE("labeled", Token::TOK_LABELED, "labeled");
  CHECK_SEMANTIC_VALUE("lABELED", Token::TOK_LABELED, "lABELED");
  CHECK_SEMANTIC_VALUE("LABELS", Token::TOK_LABELS, "LABELS");
  CHECK_SEMANTIC_VALUE("labels", Token::TOK_LABELS, "labels");
  CHECK_SEMANTIC_VALUE("LabeLS", Token::TOK_LABELS, "LabeLS");
  CHECK_SEMANTIC_VALUE("MESSAGE_TEXT", Token::TOK_MESSAGE_TEXT, "MESSAGE_TEXT");
  CHECK_SEMANTIC_VALUE("message_text", Token::TOK_MESSAGE_TEXT, "message_text");
  CHECK_SEMANTIC_VALUE("mESSAGE_text", Token::TOK_MESSAGE_TEXT, "mESSAGE_text");
  CHECK_SEMANTIC_VALUE("MORE", Token::TOK_MORE, "MORE");
  CHECK_SEMANTIC_VALUE("more", Token::TOK_MORE, "more");
  CHECK_SEMANTIC_VALUE("mOrE", Token::TOK_MORE, "mOrE");
  CHECK_SEMANTIC_VALUE("MUTABLE", Token::TOK_MUTABLE, "MUTABLE");
  CHECK_SEMANTIC_VALUE("mutable", Token::TOK_MUTABLE, "mutable");
  CHECK_SEMANTIC_VALUE("Mutable", Token::TOK_MUTABLE, "Mutable");
  CHECK_SEMANTIC_VALUE("NFC", Token::TOK_NFC, "NFC");
  CHECK_SEMANTIC_VALUE("nfc", Token::TOK_NFC, "nfc");
  CHECK_SEMANTIC_VALUE("NfC", Token::TOK_NFC, "NfC");
  CHECK_SEMANTIC_VALUE("NFD", Token::TOK_NFD, "NFD");
  CHECK_SEMANTIC_VALUE("nfd", Token::TOK_NFD, "nfd");
  CHECK_SEMANTIC_VALUE("NfD", Token::TOK_NFD, "NfD");
  CHECK_SEMANTIC_VALUE("NFKC", Token::TOK_NFKC, "NFKC");
  CHECK_SEMANTIC_VALUE("nfkc", Token::TOK_NFKC, "nfkc");
  CHECK_SEMANTIC_VALUE("NfKc", Token::TOK_NFKC, "NfKc");
  CHECK_SEMANTIC_VALUE("NFKD", Token::TOK_NFKD, "NFKD");
  CHECK_SEMANTIC_VALUE("nfkd", Token::TOK_NFKD, "nfkd");
  CHECK_SEMANTIC_VALUE("NfKd", Token::TOK_NFKD, "NfKd");
  CHECK_SEMANTIC_VALUE("NODE", Token::TOK_NODE_SYNONYM, "NODE");
  CHECK_SEMANTIC_VALUE("node", Token::TOK_NODE_SYNONYM, "node");
  CHECK_SEMANTIC_VALUE("Node", Token::TOK_NODE_SYNONYM, "Node");
  CHECK_SEMANTIC_VALUE("NODES", Token::TOK_NODES, "NODES");
  CHECK_SEMANTIC_VALUE("nodes", Token::TOK_NODES, "nodes");
  CHECK_SEMANTIC_VALUE("Nodes", Token::TOK_NODES, "Nodes");
  CHECK_SEMANTIC_VALUE("NORMALIZED", Token::TOK_NORMALIZED, "NORMALIZED");
  CHECK_SEMANTIC_VALUE("normalized", Token::TOK_NORMALIZED, "normalized");
  CHECK_SEMANTIC_VALUE("nORMALIZED", Token::TOK_NORMALIZED, "nORMALIZED");
  CHECK_SEMANTIC_VALUE("NUMBER", Token::TOK_NUMBER, "NUMBER");
  CHECK_SEMANTIC_VALUE("number", Token::TOK_NUMBER, "number");
  CHECK_SEMANTIC_VALUE("NumBer", Token::TOK_NUMBER, "NumBer");
  CHECK_SEMANTIC_VALUE("ONLY", Token::TOK_ONLY, "ONLY");
  CHECK_SEMANTIC_VALUE("only", Token::TOK_ONLY, "only");
  CHECK_SEMANTIC_VALUE("oNLY", Token::TOK_ONLY, "oNLY");
  CHECK_SEMANTIC_VALUE("ORDINALITY", Token::TOK_ORDINALITY, "ORDINALITY");
  CHECK_SEMANTIC_VALUE("ordinality", Token::TOK_ORDINALITY, "ordinality");
  CHECK_SEMANTIC_VALUE("OrdiNALITY", Token::TOK_ORDINALITY, "OrdiNALITY");
  CHECK_SEMANTIC_VALUE("PATTERN", Token::TOK_PATTERN, "PATTERN");
  CHECK_SEMANTIC_VALUE("pattern", Token::TOK_PATTERN, "pattern");
  CHECK_SEMANTIC_VALUE("PATTern", Token::TOK_PATTERN, "PATTern");
  CHECK_SEMANTIC_VALUE("PATTERNS", Token::TOK_PATTERNS, "PATTERNS");
  CHECK_SEMANTIC_VALUE("patterns", Token::TOK_PATTERNS, "patterns");
  CHECK_SEMANTIC_VALUE("PATTERns", Token::TOK_PATTERNS, "PATTERns");
  CHECK_SEMANTIC_VALUE("PROPERTY", Token::TOK_PROPERTY, "PROPERTY");
  CHECK_SEMANTIC_VALUE("property", Token::TOK_PROPERTY, "property");
  CHECK_SEMANTIC_VALUE("PRoperTY", Token::TOK_PROPERTY, "PRoperTY");
  CHECK_SEMANTIC_VALUE("PROPERTIES", Token::TOK_PROPERTIES, "PROPERTIES");
  CHECK_SEMANTIC_VALUE("properties", Token::TOK_PROPERTIES, "properties");
  CHECK_SEMANTIC_VALUE("PROPerties", Token::TOK_PROPERTIES, "PROPerties");
  CHECK_SEMANTIC_VALUE("READ", Token::TOK_READ, "READ");
  CHECK_SEMANTIC_VALUE("read", Token::TOK_READ, "read");
  CHECK_SEMANTIC_VALUE("ReaD", Token::TOK_READ, "ReaD");
  CHECK_SEMANTIC_VALUE("RELATIONSHIP", Token::TOK_EDGE_SYNONYM, "RELATIONSHIP");
  CHECK_SEMANTIC_VALUE("relationship", Token::TOK_EDGE_SYNONYM, "relationship");
  CHECK_SEMANTIC_VALUE("RelaTIONship", Token::TOK_EDGE_SYNONYM, "RelaTIONship");
  CHECK_SEMANTIC_VALUE("RELATIONSHIPS", Token::TOK_RELATIONSHIPS, "RELATIONSHIPS");
  CHECK_SEMANTIC_VALUE("relationships", Token::TOK_RELATIONSHIPS, "relationships");
  CHECK_SEMANTIC_VALUE("RELATIONShips", Token::TOK_RELATIONSHIPS, "RELATIONShips");
  CHECK_SEMANTIC_VALUE("RETURNED_GQLSTATUS", Token::TOK_RETURNED_GQLSTATUS, "RETURNED_GQLSTATUS");
  CHECK_SEMANTIC_VALUE("returned_gqlstatus", Token::TOK_RETURNED_GQLSTATUS, "returned_gqlstatus");
  CHECK_SEMANTIC_VALUE("Returned_GqlStatus", Token::TOK_RETURNED_GQLSTATUS, "Returned_GqlStatus");
  CHECK_SEMANTIC_VALUE("SHORTEST", Token::TOK_SHORTEST, "SHORTEST");
  CHECK_SEMANTIC_VALUE("shortest", Token::TOK_SHORTEST, "shortest");
  CHECK_SEMANTIC_VALUE("Shortest", Token::TOK_SHORTEST, "Shortest");
  CHECK_SEMANTIC_VALUE("SIMPLE", Token::TOK_SIMPLE, "SIMPLE");
  CHECK_SEMANTIC_VALUE("simple", Token::TOK_SIMPLE, "simple");
  CHECK_SEMANTIC_VALUE("SIMple", Token::TOK_SIMPLE, "SIMple");
  CHECK_SEMANTIC_VALUE("SOURCE", Token::TOK_SOURCE, "SOURCE");
  CHECK_SEMANTIC_VALUE("source", Token::TOK_SOURCE, "source");
  CHECK_SEMANTIC_VALUE("SOURCe", Token::TOK_SOURCE, "SOURCe");
  CHECK_SEMANTIC_VALUE("SUBCLASS_ORIGIN", Token::TOK_SUBCLASS_ORIGIN, "SUBCLASS_ORIGIN");
  CHECK_SEMANTIC_VALUE("subclass_origin", Token::TOK_SUBCLASS_ORIGIN, "subclass_origin");
  CHECK_SEMANTIC_VALUE("Subclass_Origin", Token::TOK_SUBCLASS_ORIGIN, "Subclass_Origin");
  CHECK_SEMANTIC_VALUE("TABLE", Token::TOK_BINDING_TABLE_SYNONYM, "TABLE");
  CHECK_SEMANTIC_VALUE("table", Token::TOK_BINDING_TABLE_SYNONYM, "table");
  CHECK_SEMANTIC_VALUE("Table", Token::TOK_BINDING_TABLE_SYNONYM, "Table");
  CHECK_SEMANTIC_VALUE("TABLES", Token::TOK_TABLES, "TABLES");
  CHECK_SEMANTIC_VALUE("tables", Token::TOK_TABLES, "tables");
  CHECK_SEMANTIC_VALUE("Tables", Token::TOK_TABLES, "Tables");
  CHECK_SEMANTIC_VALUE("TIES", Token::TOK_TIES, "TIES");
  CHECK_SEMANTIC_VALUE("ties", Token::TOK_TIES, "ties");
  CHECK_SEMANTIC_VALUE("Ties", Token::TOK_TIES, "Ties");
  CHECK_SEMANTIC_VALUE("TO", Token::TOK_TO, "TO");
  CHECK_SEMANTIC_VALUE("to", Token::TOK_TO, "to");
  CHECK_SEMANTIC_VALUE("tO", Token::TOK_TO, "tO");
  CHECK_SEMANTIC_VALUE("TRAIL", Token::TOK_TRAIL, "TRAIL");
  CHECK_SEMANTIC_VALUE("trail", Token::TOK_TRAIL, "trail");
  CHECK_SEMANTIC_VALUE("Trail", Token::TOK_TRAIL, "Trail");
  CHECK_SEMANTIC_VALUE("TRANSACTION", Token::TOK_TRANSACTION, "TRANSACTION");
  CHECK_SEMANTIC_VALUE("transaction", Token::TOK_TRANSACTION, "transaction");
  CHECK_SEMANTIC_VALUE("TRANSaction", Token::TOK_TRANSACTION, "TRANSaction");
  CHECK_SEMANTIC_VALUE("TYPE", Token::TOK_TYPE, "TYPE");
  CHECK_SEMANTIC_VALUE("type", Token::TOK_TYPE, "type");
  CHECK_SEMANTIC_VALUE("TYpe", Token::TOK_TYPE, "TYpe");
  CHECK_SEMANTIC_VALUE("TYPES", Token::TOK_TYPES, "TYPES");
  CHECK_SEMANTIC_VALUE("types", Token::TOK_TYPES, "types");
  CHECK_SEMANTIC_VALUE("Types", Token::TOK_TYPES, "Types");
  CHECK_SEMANTIC_VALUE("UNDIRECTED", Token::TOK_UNDIRECTED, "UNDIRECTED");
  CHECK_SEMANTIC_VALUE("undirected", Token::TOK_UNDIRECTED, "undirected");
  CHECK_SEMANTIC_VALUE("UNDIrectED", Token::TOK_UNDIRECTED, "UNDIrectED");
  CHECK_SEMANTIC_VALUE("VERTEX", Token::TOK_NODE_SYNONYM, "VERTEX");
  CHECK_SEMANTIC_VALUE("vertex", Token::TOK_NODE_SYNONYM, "vertex");
  CHECK_SEMANTIC_VALUE("VerTEX", Token::TOK_NODE_SYNONYM, "VerTEX");
  CHECK_SEMANTIC_VALUE("VERTICES", Token::TOK_VERTICES, "VERTICES");
  CHECK_SEMANTIC_VALUE("vertices", Token::TOK_VERTICES, "vertices");
  CHECK_SEMANTIC_VALUE("Vertices", Token::TOK_VERTICES, "Vertices");
  CHECK_SEMANTIC_VALUE("WALK", Token::TOK_WALK, "WALK");
  CHECK_SEMANTIC_VALUE("walk", Token::TOK_WALK, "walk");
  CHECK_SEMANTIC_VALUE("Walk", Token::TOK_WALK, "Walk");
  CHECK_SEMANTIC_VALUE("WRITE", Token::TOK_WRITE, "WRITE");
  CHECK_SEMANTIC_VALUE("write", Token::TOK_WRITE, "write");
  CHECK_SEMANTIC_VALUE("WRite", Token::TOK_WRITE, "WRite");
  CHECK_SEMANTIC_VALUE("ZONE", Token::TOK_ZONE, "ZONE");
  CHECK_SEMANTIC_VALUE("zone", Token::TOK_ZONE, "zone");
  CHECK_SEMANTIC_VALUE("ZonE", Token::TOK_ZONE, "ZonE");
}

TEST_F(ScannerTest, Special) {
  CHECK_SEMANTIC_TYPE("IS SOURCE", Token::TOK_IS_SOURCE);
  CHECK_SEMANTIC_TYPE("IS NOT SOURCE", Token::TOK_IS_NOT_SOURCE);
  CHECK_SEMANTIC_TYPE("IS DESTINATION", Token::TOK_IS_DESTINATION);
  CHECK_SEMANTIC_TYPE("IS NOT DESTINATION", Token::TOK_IS_NOT_DESTINATION);
  CHECK_SEMANTIC_TYPE("IS NULL", Token::TOK_IS_NULL);
  CHECK_SEMANTIC_TYPE("IS NOT NULL", Token::TOK_IS_NOT_NULL);
  CHECK_SEMANTIC_TYPE("IS NOT", Token::TOK_IS_NOT);
  CHECK_SEMANTIC_TYPE("IS DIRECTED", Token::TOK_IS_DIRECTED);
  CHECK_SEMANTIC_TYPE("IS NOT DIRECTED", Token::TOK_IS_NOT_DIRECTED);
  CHECK_SEMANTIC_TYPE("IS LABELED", Token::TOK_IS_LABELED);
  CHECK_SEMANTIC_TYPE("IS NOT LABELED", Token::TOK_IS_NOT_LABELED);
  CHECK_SEMANTIC_TYPE("SESSION CLOSE", Token::TOK_SESSION_CLOSE);
  CHECK_SEMANTIC_TYPE("GROUP BY", Token::TOK_GROUP_BY);
  CHECK_SEMANTIC_TYPE("GRAPH", Token::TOK_GRAPH_SYNONYM);
  CHECK_SEMANTIC_TYPE("PROPERTY GRAPH", Token::TOK_GRAPH_SYNONYM);
  CHECK_SEMANTIC_TYPE("GRAPH TYPE", Token::TOK_GRAPH_TYPE_SYNONYM);
  CHECK_SEMANTIC_TYPE("PROPERTY GRAPH TYPE", Token::TOK_GRAPH_TYPE_SYNONYM);
  CHECK_SEMANTIC_TYPE("TABLE", Token::TOK_BINDING_TABLE_SYNONYM);
  CHECK_SEMANTIC_TYPE("BINDING TABLE", Token::TOK_BINDING_TABLE_SYNONYM);
  CHECK_SEMANTIC_TYPE("/..", Token::TOK_SOLIDUS_DOUBLE_PERIOD);
}

TEST_F(ScannerTest, RegularIdentifier) {
  CHECK_SEMANTIC_VALUE("abc", Token::TOK_REGULAR_IDENTIFIER, "abc");
  CHECK_SEMANTIC_VALUE("a_b_c", Token::TOK_REGULAR_IDENTIFIER, "a_b_c");
  CHECK_SEMANTIC_VALUE("a123", Token::TOK_REGULAR_IDENTIFIER, "a123");
  CHECK_SEMANTIC_VALUE("中国", Token::TOK_REGULAR_IDENTIFIER, "中国");
  CHECK_SEMANTIC_VALUE("a中国", Token::TOK_REGULAR_IDENTIFIER, "a中国");
  CHECK_SEMANTIC_VALUE("中国a", Token::TOK_REGULAR_IDENTIFIER, "中国a");
  CHECK_SEMANTIC_VALUE("a中b国c", Token::TOK_REGULAR_IDENTIFIER, "a中b国c");
  // The case-sensitive keywords are regarded as regular identifiers if they
  // are not the specified case form
  CHECK_SEMANTIC_VALUE("ENDNODE", Token::TOK_REGULAR_IDENTIFIER, "ENDNODE");
  CHECK_SEMANTIC_VALUE("endnode", Token::TOK_REGULAR_IDENTIFIER, "endnode");
  CHECK_SEMANTIC_VALUE("endNoDe", Token::TOK_REGULAR_IDENTIFIER, "endNoDe");
  CHECK_SEMANTIC_VALUE("INDEGREE", Token::TOK_REGULAR_IDENTIFIER, "INDEGREE");
  CHECK_SEMANTIC_VALUE("indegree", Token::TOK_REGULAR_IDENTIFIER, "indegree");
  CHECK_SEMANTIC_VALUE("INDegree", Token::TOK_REGULAR_IDENTIFIER, "INDegree");
  CHECK_SEMANTIC_VALUE("LTRIM", Token::TOK_REGULAR_IDENTIFIER, "LTRIM");
  CHECK_SEMANTIC_VALUE("ltrim", Token::TOK_REGULAR_IDENTIFIER, "ltrim");
  CHECK_SEMANTIC_VALUE("ltrIM", Token::TOK_REGULAR_IDENTIFIER, "ltrIM");
  CHECK_SEMANTIC_VALUE("OUTDEGREE", Token::TOK_REGULAR_IDENTIFIER, "OUTDEGREE");
  CHECK_SEMANTIC_VALUE("outdegree", Token::TOK_REGULAR_IDENTIFIER, "outdegree");
  CHECK_SEMANTIC_VALUE("OuTdeGree", Token::TOK_REGULAR_IDENTIFIER, "OuTdeGree");
  CHECK_SEMANTIC_VALUE("PERCENTILECONT", Token::TOK_REGULAR_IDENTIFIER, "PERCENTILECONT");
  CHECK_SEMANTIC_VALUE("percentilecont", Token::TOK_REGULAR_IDENTIFIER, "percentilecont");
  CHECK_SEMANTIC_VALUE("perCEntileCoNt", Token::TOK_REGULAR_IDENTIFIER, "perCEntileCoNt");
  CHECK_SEMANTIC_VALUE("PERCENTILEDIST", Token::TOK_REGULAR_IDENTIFIER, "PERCENTILEDIST");
  CHECK_SEMANTIC_VALUE("percentiledist", Token::TOK_REGULAR_IDENTIFIER, "percentiledist");
  CHECK_SEMANTIC_VALUE("peRCentiledISt", Token::TOK_REGULAR_IDENTIFIER, "peRCentiledISt");
  CHECK_SEMANTIC_VALUE("RTRIM", Token::TOK_REGULAR_IDENTIFIER, "RTRIM");
  CHECK_SEMANTIC_VALUE("rtrim", Token::TOK_REGULAR_IDENTIFIER, "rtrim");
  CHECK_SEMANTIC_VALUE("rTRim", Token::TOK_REGULAR_IDENTIFIER, "rTRim");
  CHECK_SEMANTIC_VALUE("STARTNODE", Token::TOK_REGULAR_IDENTIFIER, "STARTNODE");
  CHECK_SEMANTIC_VALUE("startnode", Token::TOK_REGULAR_IDENTIFIER, "startnode");
  CHECK_SEMANTIC_VALUE("starTNODE", Token::TOK_REGULAR_IDENTIFIER, "starTNODE");
  CHECK_SEMANTIC_VALUE("STDEV", Token::TOK_REGULAR_IDENTIFIER, "STDEV");
  CHECK_SEMANTIC_VALUE("stdev", Token::TOK_REGULAR_IDENTIFIER, "stdev");
  CHECK_SEMANTIC_VALUE("sTdeV", Token::TOK_REGULAR_IDENTIFIER, "sTdeV");
  CHECK_SEMANTIC_VALUE("STDEVP", Token::TOK_REGULAR_IDENTIFIER, "STDEVP");
  CHECK_SEMANTIC_VALUE("stdevp", Token::TOK_REGULAR_IDENTIFIER, "stdevp");
  CHECK_SEMANTIC_VALUE("STdVp", Token::TOK_REGULAR_IDENTIFIER, "STdVp");
  CHECK_SEMANTIC_VALUE("TAIL", Token::TOK_REGULAR_IDENTIFIER, "TAIL");
  CHECK_SEMANTIC_VALUE("tAIl", Token::TOK_REGULAR_IDENTIFIER, "tAIl");
  CHECK_SEMANTIC_VALUE("tAIL", Token::TOK_REGULAR_IDENTIFIER, "tAIL");
  CHECK_SEMANTIC_VALUE("TOLOWER", Token::TOK_REGULAR_IDENTIFIER, "TOLOWER");
  CHECK_SEMANTIC_VALUE("tolower", Token::TOK_REGULAR_IDENTIFIER, "tolower");
  CHECK_SEMANTIC_VALUE("toLOWER", Token::TOK_REGULAR_IDENTIFIER, "toLOWER");
  CHECK_SEMANTIC_VALUE("TOUPPER", Token::TOK_REGULAR_IDENTIFIER, "TOUPPER");
  CHECK_SEMANTIC_VALUE("toupper", Token::TOK_REGULAR_IDENTIFIER, "toupper");
  CHECK_SEMANTIC_VALUE("TouPPer", Token::TOK_REGULAR_IDENTIFIER, "TouPPer");
}

TEST_F(ScannerTest, ParameterName1) {
  CHECK_SEMANTIC_VALUE("$param", Token::TOK_PARAMETER_NAME_1, "param");
  CHECK_SEMANTIC_VALUE("$param123", Token::TOK_PARAMETER_NAME_1, "param123");
  CHECK_SEMANTIC_VALUE("$LALALAND", Token::TOK_PARAMETER_NAME_1, "LALALAND");
  CHECK_SEMANTIC_VALUE("$123", Token::TOK_PARAMETER_NAME_1, "123");
  CHECK_SEMANTIC_VALUE("$_", Token::TOK_PARAMETER_NAME_1, "_");
  CHECK_SEMANTIC_VALUE("$__abc", Token::TOK_PARAMETER_NAME_1, "__abc");
  CHECK_SEMANTIC_VALUE("$美利坚", Token::TOK_PARAMETER_NAME_1, "美利坚");
  CHECK_SEMANTIC_VALUE("$__中国abc", Token::TOK_PARAMETER_NAME_1, "__中国abc");
}

TEST_F(ScannerTest, SingleQuotedCharacterSequence) {
  // unbroken single quoted character sequence
  CHECK_SEMANTIC_VALUE("'abc'", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "abc");
  CHECK_SEMANTIC_VALUE("'ab\\\\c'", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\\c");
  CHECK_SEMANTIC_VALUE("'ab\\\'c'", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab'c");
  CHECK_SEMANTIC_VALUE("'ab\\\"c'", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\"c");
  CHECK_SEMANTIC_VALUE("'ab\"c'", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\"c");
  CHECK_SEMANTIC_VALUE("'ab\\tc'", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\tc");
  CHECK_SEMANTIC_VALUE("'ab\\bc'", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\bc");
  CHECK_SEMANTIC_VALUE("'ab\\nc'", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\nc");
  CHECK_SEMANTIC_VALUE("'ab\\rc'", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\rc");
  CHECK_SEMANTIC_VALUE("'ab\\fc'", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\fc");
  CHECK_SEMANTIC_VALUE(
      "'ab\\u4e2d\\u56fdc'", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab中国c");
  CHECK_SEMANTIC_VALUE("'ab😀😉c'", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab😀😉c");
  CHECK_SEMANTIC_VALUE(
      "'ab\\U01f525c'", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab🔥c");
  CHECK_SEMANTIC_VALUE(
      "'ab\\U01F600c'", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab😀c");
  CHECK_SEMANTIC_VALUE("'ab\\u007Bxyz\\U01F609\\U01F600c'",
                       Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE,
                       "ab{xyz😉😀c");
  // broken single quoted character sequence
  CHECK_SEMANTIC_VALUE(
      "'abc' \n 'def'", Token::TOK_BROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "abcdef");
  CHECK_SEMANTIC_VALUE(
      "'abc' \n\r  'def'", Token::TOK_BROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "abcdef");
  CHECK_SEMANTIC_VALUE("'abc' /* some \n comment */  'def'",
                       Token::TOK_BROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE,
                       "abcdef");
  CHECK_SEMANTIC_VALUE("'abc' // some comment \n 'def'",
                       Token::TOK_BROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE,
                       "abcdef");
  CHECK_SEMANTIC_VALUE("'ab\\u4e2dc' // some comment \n 'def'    \n\r\t\f '\\u56fd\\U01F600wxyz'",
                       Token::TOK_BROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE,
                       "ab中cdef国😀wxyz");
}

TEST_F(ScannerTest, DoubleQuotedCharacterSequence) {
  // unbroken double quoted character sequence
  CHECK_SEMANTIC_VALUE("\"abc\"", Token::TOK_UNBROKEN_DOUBLE_QUOTED_CHARACTER_SEQUENCE, "abc");
  CHECK_SEMANTIC_VALUE(
      "\"ab\\\\c\"", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\\c");
  CHECK_SEMANTIC_VALUE("\"ab\\\'c\"", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab'c");
  CHECK_SEMANTIC_VALUE(
      "\"ab\\\"c\"", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\"c");
  CHECK_SEMANTIC_VALUE("\"ab\'c\"", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\'c");
  CHECK_SEMANTIC_VALUE("\"ab\\tc\"", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\tc");
  CHECK_SEMANTIC_VALUE("\"ab\\bc\"", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\bc");
  CHECK_SEMANTIC_VALUE("\"ab\\nc\"", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\nc");
  CHECK_SEMANTIC_VALUE("\"ab\\rc\"", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\rc");
  CHECK_SEMANTIC_VALUE("\"ab\\fc\"", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\fc");
  CHECK_SEMANTIC_VALUE(
      "\"ab\\u4e2d\\u56fdc\"", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab中国c");
  CHECK_SEMANTIC_VALUE("\"ab😀😉c\"", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab😀😉c");
  CHECK_SEMANTIC_VALUE(
      "\"ab\\U01f525c\"", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab🔥c");
  CHECK_SEMANTIC_VALUE(
      "\"ab\\U01F600c\"", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab😀c");
  CHECK_SEMANTIC_VALUE("\"ab\\u007Bxyz\\U01F609\\U01F600c\"",
                       Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE,
                       "ab{xyz😉😀c");
  // broken double quoted character sequence
  CHECK_SEMANTIC_VALUE(
      "\"abc\" \n \"def\"", Token::TOK_BROKEN_DOUBLE_QUOTED_CHARACTER_SEQUENCE, "abcdef");
  CHECK_SEMANTIC_VALUE(
      "\"abc\" \n\r  \"def\"", Token::TOK_BROKEN_DOUBLE_QUOTED_CHARACTER_SEQUENCE, "abcdef");
  CHECK_SEMANTIC_VALUE("\"abc\" /* some \n comment */  \"def\"",
                       Token::TOK_BROKEN_DOUBLE_QUOTED_CHARACTER_SEQUENCE,
                       "abcdef");
  CHECK_SEMANTIC_VALUE("\"abc\" // some comment \n \"def\"",
                       Token::TOK_BROKEN_DOUBLE_QUOTED_CHARACTER_SEQUENCE,
                       "abcdef");
  CHECK_SEMANTIC_VALUE(
      "\"ab\\u4e2dc\" // some comment \n \"def\"    \n\r\t\f \"\\u56fd\\U01F600wxyz\"",
      Token::TOK_BROKEN_DOUBLE_QUOTED_CHARACTER_SEQUENCE,
      "ab中cdef国😀wxyz");
}

TEST_F(ScannerTest, UnbrokenAccentQuotedString) {
  // unbroken accent quoted character sequence
  CHECK_SEMANTIC_VALUE("`abc`", Token::TOK_UNBROKEN_ACCENT_QUOTED_CHARACTER_SEQUENCE, "abc");
  CHECK_SEMANTIC_VALUE("`ab\\\\c`", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\\c");
  CHECK_SEMANTIC_VALUE("`ab\\\'c`", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab'c");
  CHECK_SEMANTIC_VALUE("`ab\\\"c`", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\"c");
  CHECK_SEMANTIC_VALUE("`ab\'c`", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\'c");
  CHECK_SEMANTIC_VALUE("`ab\"c`", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\"c");
  CHECK_SEMANTIC_VALUE("`ab\\tc`", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\tc");
  CHECK_SEMANTIC_VALUE("`ab\\bc`", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\bc");
  CHECK_SEMANTIC_VALUE("`ab\\nc`", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\nc");
  CHECK_SEMANTIC_VALUE("`ab\\rc`", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\rc");
  CHECK_SEMANTIC_VALUE("`ab\\fc`", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab\fc");
  CHECK_SEMANTIC_VALUE(
      "`ab\\u4e2d\\u56fdc`", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab中国c");
  CHECK_SEMANTIC_VALUE("`ab😀😉c`", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab😀😉c");
  CHECK_SEMANTIC_VALUE(
      "`ab\\U01f525c`", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab🔥c");
  CHECK_SEMANTIC_VALUE(
      "`ab\\U01F600c`", Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE, "ab😀c");
  CHECK_SEMANTIC_VALUE("`ab\\u007Bxyz\\U01F609\\U01F600c`",
                       Token::TOK_UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE,
                       "ab{xyz😉😀c");
}

TEST_F(ScannerTest, ByteStringLiteral) {
  // byte string literal
  CHECK_SEMANTIC_VALUE("x'0123'", Token::TOK_BYTE_STRING_LITERAL, "\x01\x23");
  CHECK_SEMANTIC_VALUE("x'38afde5a'", Token::TOK_BYTE_STRING_LITERAL, "\x38\xaf\xde\x5a");
  CHECK_SEMANTIC_VALUE(
      "x'0123456789abcdef'", Token::TOK_BYTE_STRING_LITERAL, "\x01\x23\x45\x67\x89\xab\xcd\xef");
  CHECK_SEMANTIC_VALUE("x'  01 23 45 67 89 ab cd    ef'",
                       Token::TOK_BYTE_STRING_LITERAL,
                       "\x01\x23\x45\x67\x89\xab\xcd\xef");
  CHECK_SEMANTIC_VALUE("x'  01 23 ' \n  '45 67 89 ab cd    ef'",
                       Token::TOK_BYTE_STRING_LITERAL,
                       "\x01\x23\x45\x67\x89\xab\xcd\xef");
  CHECK_SEMANTIC_VALUE("x'  01 23 ' \n\r  '45 67 89 ab cd    ef'",
                       Token::TOK_BYTE_STRING_LITERAL,
                       "\x01\x23\x45\x67\x89\xab\xcd\xef");
  CHECK_SEMANTIC_VALUE("x'  01 23 '/* some comment \n ***/  '45 67 89 ab cd    ef'",
                       Token::TOK_BYTE_STRING_LITERAL,
                       "\x01\x23\x45\x67\x89\xab\xcd\xef");
  CHECK_SEMANTIC_VALUE("x'  01 23 '/* some comment \n ***/  '45 67 89 ab cd    ef'",
                       Token::TOK_BYTE_STRING_LITERAL,
                       "\x01\x23\x45\x67\x89\xab\xcd\xef");
  CHECK_SEMANTIC_VALUE("x'  01 23 '/* some comment \n ***/  '45 67 89 ab cd    ef' \n\r\t\f'a8ff'",
                       Token::TOK_BYTE_STRING_LITERAL,
                       "\x01\x23\x45\x67\x89\xab\xcd\xef\xa8\xff");
  CHECK_LEXICAL_ERROR("x'01 2'", "Invalid byte string literal: ");
}

TEST_F(ScannerTest, UnsignedDecimalInteger) {
  CHECK_SEMANTIC_VALUE("123", Token::TOK_UNSIGNED_INTEGER, 123);
  CHECK_SEMANTIC_VALUE("0123", Token::TOK_UNSIGNED_INTEGER, 123);
  CHECK_SEMANTIC_VALUE("1_2_3", Token::TOK_UNSIGNED_INTEGER, 123);
  CHECK_SEMANTIC_VALUE("12_39_8", Token::TOK_UNSIGNED_INTEGER, 12398);
}

TEST_F(ScannerTest, UnsignedHexadecimalInteger) {
  CHECK_SEMANTIC_VALUE("0x123", Token::TOK_UNSIGNED_INTEGER, 0x123);
  CHECK_SEMANTIC_VALUE("0x0123", Token::TOK_UNSIGNED_INTEGER, 0x123);
  CHECK_SEMANTIC_VALUE("0x_128fe", Token::TOK_UNSIGNED_INTEGER, 0x128fe);
  CHECK_SEMANTIC_VALUE("0x_128Fe", Token::TOK_UNSIGNED_INTEGER, 0x128fe);
  CHECK_SEMANTIC_VALUE("0x_1_28_fe", Token::TOK_UNSIGNED_INTEGER, 0x128fe);
  CHECK_SEMANTIC_VALUE("0x_1_28_FE", Token::TOK_UNSIGNED_INTEGER, 0x128fe);
}

TEST_F(ScannerTest, UnsignedOctalInteger) {
  CHECK_SEMANTIC_VALUE("0o123", Token::TOK_UNSIGNED_INTEGER, 0123);
  CHECK_SEMANTIC_VALUE("0o0123", Token::TOK_UNSIGNED_INTEGER, 0123);
  CHECK_SEMANTIC_VALUE("0o_123", Token::TOK_UNSIGNED_INTEGER, 0123);
  CHECK_SEMANTIC_VALUE("0o_1_237_77", Token::TOK_UNSIGNED_INTEGER, 0123777);
}

TEST_F(ScannerTest, UnsignedBinaryInteger) {
  CHECK_SEMANTIC_VALUE("0b101", Token::TOK_UNSIGNED_INTEGER, 0b101);
  CHECK_SEMANTIC_VALUE("0b0101", Token::TOK_UNSIGNED_INTEGER, 0b101);
  CHECK_SEMANTIC_VALUE("0b_101", Token::TOK_UNSIGNED_INTEGER, 0b101);
  CHECK_SEMANTIC_VALUE("0b_1_01_01", Token::TOK_UNSIGNED_INTEGER, 0b10101);
}

TEST_F(ScannerTest, UnsignedFloatingPoint) {
  CHECK_SEMANTIC_VALUE("123.", Token::TOK_UNSIGNED_FLOATING_POINT, 123.0);
  CHECK_SEMANTIC_VALUE("123.456", Token::TOK_UNSIGNED_FLOATING_POINT, 123.456);
  CHECK_SEMANTIC_VALUE(".456", Token::TOK_UNSIGNED_FLOATING_POINT, 0.456);
  CHECK_SEMANTIC_VALUE("123.456e-7", Token::TOK_UNSIGNED_FLOATING_POINT, 123.456e-7);
  CHECK_SEMANTIC_VALUE("123.456E-7", Token::TOK_UNSIGNED_FLOATING_POINT, 123.456e-7);
  CHECK_SEMANTIC_VALUE("123.456e+7", Token::TOK_UNSIGNED_FLOATING_POINT, 123.456e7);
  CHECK_SEMANTIC_VALUE("123.456E+7", Token::TOK_UNSIGNED_FLOATING_POINT, 123.456e7);
  CHECK_SEMANTIC_VALUE("123.456e7", Token::TOK_UNSIGNED_FLOATING_POINT, 123.456e7);
  CHECK_SEMANTIC_VALUE("123.456E7", Token::TOK_UNSIGNED_FLOATING_POINT, 123.456e7);
  CHECK_SEMANTIC_VALUE("123.e7", Token::TOK_UNSIGNED_FLOATING_POINT, 123.0e7);
  CHECK_SEMANTIC_VALUE("123.E7", Token::TOK_UNSIGNED_FLOATING_POINT, 123.0e7);
  CHECK_SEMANTIC_VALUE(".123e7", Token::TOK_UNSIGNED_FLOATING_POINT, 0.123e7);
  CHECK_SEMANTIC_VALUE(".123E7", Token::TOK_UNSIGNED_FLOATING_POINT, 0.123e7);
  // TODO: test some overfloat numeric
}

TEST_F(ScannerTest, Tokens) {
  CHECK_SEMANTIC_TYPES("MATCH (v:player) RETURN v.age + 1",
                       (std::vector<TokenType>{Token::TOK_MATCH,
                                               Token::TOK_LEFT_PAREN,
                                               Token::TOK_REGULAR_IDENTIFIER,
                                               Token::TOK_COLON,
                                               Token::TOK_REGULAR_IDENTIFIER,
                                               Token::TOK_RIGHT_PAREN,
                                               Token::TOK_RETURN,
                                               Token::TOK_REGULAR_IDENTIFIER,
                                               Token::TOK_PERIOD,
                                               Token::TOK_REGULAR_IDENTIFIER,
                                               Token::TOK_PLUS_SIGN,
                                               Token::TOK_UNSIGNED_INTEGER,
                                               Token::TOK_YYEOF}));
  CHECK_SEMANTIC_TYPES("INSERT (v:player&team{name: 'Tony '\n'Parker'}) WHEN TRUE",
                       (std::vector<TokenType>{Token::TOK_INSERT,
                                               Token::TOK_LEFT_PAREN,
                                               Token::TOK_REGULAR_IDENTIFIER,
                                               Token::TOK_COLON,
                                               Token::TOK_REGULAR_IDENTIFIER,
                                               Token::TOK_AMPERSAND,
                                               Token::TOK_REGULAR_IDENTIFIER,
                                               Token::TOK_LEFT_BRACE,
                                               Token::TOK_REGULAR_IDENTIFIER,
                                               Token::TOK_COLON,
                                               Token::TOK_BROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE,
                                               Token::TOK_RIGHT_BRACE,
                                               Token::TOK_RIGHT_PAREN,
                                               Token::TOK_WHEN,
                                               Token::TOK_TRUE,
                                               Token::TOK_YYEOF}));
  CHECK_SEMANTIC_TYPES("startNode * is not /* a comment\n */ LAbeled $123 / 0o_774",
                       (std::vector<TokenType>{Token::TOK_startNode,
                                               Token::TOK_ASTERISK,
                                               Token::TOK_IS_NOT_LABELED,
                                               Token::TOK_PARAMETER_NAME_1,
                                               Token::TOK_SOLIDUS,
                                               Token::TOK_UNSIGNED_INTEGER,
                                               Token::TOK_YYEOF}));
}

}  // namespace nebula
