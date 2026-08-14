const std = @import("std");

pub const TokenTag = enum {
    identifier,
    integer,
    string,
    keyword_mutable,
    keyword_if,
    keyword_else,
    keyword_while,
    keyword_print,
    keyword_true,
    keyword_false,
    keyword_begin,
    keyword_end,
    keyword_becomes,
    keyword_add,
    keyword_subtract,
    keyword_multiply,
    keyword_divide,
    keyword_remainder,
    keyword_equals,
    keyword_not_equals,
    keyword_greater,
    keyword_less,
    keyword_at_least,
    keyword_at_most,
    keyword_and,
    keyword_or,
    keyword_not,
    l_paren,
    r_paren,
    comma,
    newline,
    eof,
};

pub const Token = struct {
    tag: TokenTag,
    lexeme: []const u8,
    line: usize,
    column: usize,
};

pub const LexError = error{ LatinLetterForbidden, UnexpectedCharacter, UnterminatedString };

pub fn lex(allocator: std.mem.Allocator, source: []const u8) ![]Token {
    var out: std.ArrayList(Token) = .empty;
    errdefer out.deinit(allocator);
    var i: usize = 0;
    var line: usize = 1;
    var column: usize = 1;

    while (i < source.len) {
        const c = source[i];
        if (c == ' ' or c == '\t' or c == '\r') { i += 1; column += 1; continue; }
        if (c == '\n') {
            try out.append(allocator, .{ .tag=.newline, .lexeme=source[i..i+1], .line=line, .column=column });
            i += 1; line += 1; column = 1; continue;
        }
        if (c == '/' and i + 1 < source.len and source[i+1] == '/') {
            i += 2; column += 2;
            while (i < source.len and source[i] != '\n') { i += 1; column += 1; }
            continue;
        }
        if (c == '(' or c == ')' or c == ',') {
            const tag: TokenTag = if (c == '(') .l_paren else if (c == ')') .r_paren else .comma;
            try out.append(allocator, .{ .tag=tag, .lexeme=source[i..i+1], .line=line, .column=column });
            i += 1; column += 1; continue;
        }
        if (c == '"') {
            const start=i; const start_column=column;
            i += 1; column += 1;
            while (i < source.len and source[i] != '"') {
                if (source[i] == '\n') return LexError.UnterminatedString;
                i += 1; column += 1;
            }
            if (i >= source.len) return LexError.UnterminatedString;
            i += 1; column += 1;
            try out.append(allocator, .{ .tag=.string, .lexeme=source[start..i], .line=line, .column=start_column });
            continue;
        }
        if (c >= '0' and c <= '9') {
            const start=i; const start_column=column;
            while (i < source.len and source[i] >= '0' and source[i] <= '9') { i += 1; column += 1; }
            try out.append(allocator, .{ .tag=.integer, .lexeme=source[start..i], .line=line, .column=start_column });
            continue;
        }
        if ((c >= 'A' and c <= 'Z') or (c >= 'a' and c <= 'z')) return LexError.LatinLetterForbidden;

        const start=i; const start_column=column;
        while (i < source.len) {
            const b=source[i];
            if (b == ' ' or b == '\t' or b == '\r' or b == '\n' or b == '(' or b == ')' or b == ',' or b == '"') break;
            if ((b >= 'A' and b <= 'Z') or (b >= 'a' and b <= 'z')) return LexError.LatinLetterForbidden;
            i += 1; column += 1;
        }
        if (start == i) return LexError.UnexpectedCharacter;
        const word=source[start..i];
        try out.append(allocator, .{ .tag=keywordTag(word) orelse .identifier, .lexeme=word, .line=line, .column=start_column });
    }

    try out.append(allocator, .{ .tag=.eof, .lexeme="", .line=line, .column=column });
    return try out.toOwnedSlice(allocator);
}

fn keywordTag(word: []const u8) ?TokenTag {
    const pairs = [_]struct{ []const u8, TokenTag }{
        .{ "мінливе", .keyword_mutable },
        .{ "позаяк", .keyword_if },
        .{ "одначе", .keyword_else },
        .{ "допоки", .keyword_while },
        .{ "вивести", .keyword_print },
        .{ "авжеж", .keyword_true },
        .{ "ані", .keyword_false },
        .{ "зачин", .keyword_begin },
        .{ "край", .keyword_end },
        .{ "стає", .keyword_becomes },
        .{ "додати", .keyword_add },
        .{ "відняти", .keyword_subtract },
        .{ "помножити", .keyword_multiply },
        .{ "поділити", .keyword_divide },
        .{ "остача", .keyword_remainder },
        .{ "дорівнює", .keyword_equals },
        .{ "недорівнює", .keyword_not_equals },
        .{ "перевищує", .keyword_greater },
        .{ "менше", .keyword_less },
        .{ "щонайменше", .keyword_at_least },
        .{ "щонайбільше", .keyword_at_most },
        .{ "і", .keyword_and },
        .{ "або", .keyword_or },
        .{ "не", .keyword_not },
    };
    for (pairs) |pair| if (std.mem.eql(u8, word, pair[0])) return pair[1];
    return null;
}
