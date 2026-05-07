#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <map>
#include <sstream>
#include <bitset>
#include <algorithm>

using namespace std;

// 레지스터 번호 매핑
map<string, int> reg_map = 
{
    {"$zero", 0}, {"$v0", 2}, {"$v1", 3}, {"$a0", 4}, {"$a1", 5}, {"$a2", 6}, {"$a3", 7},
    {"$t0", 8}, {"$t1", 9}, {"$t2", 10}, {"$t3", 11}, {"$t4", 12}, {"$t5", 13}, {"$t6", 14}, {"$t7", 15},
    {"$s0", 16}, {"$s1", 17}, {"$s2", 18}, {"$s3", 19}, {"$s4", 20}, {"$s5", 21}, {"$s6", 22}, {"$s7", 23},
    {"$t8", 24}, {"$t9", 25}, {"$gp", 28}, {"$sp", 29}, {"$fp", 30}, {"$ra", 31}
};

// instruction 정보 구조체 (포맷 타입, Opcode, Funct 값)
struct InstInfo {
    string type;
    string opcode;
    string funct;
};

// instruction 매핑
map<string, InstInfo> inst_map = 
{
    {"add", {"R", "000000", "100000"}}, {"sub", {"R", "000000", "100010"}},
    {"and", {"R", "000000", "100100"}}, {"or", {"R", "000000", "100101"}},
    {"xor", {"R", "000000", "100110"}}, {"nor", {"R", "000000", "100111"}},
    {"slt", {"R", "000000", "101010"}}, {"sll", {"R", "000000", "000000"}},
    {"srl", {"R", "000000", "000010"}}, {"jr", {"R", "000000", "001000"}},
    {"addi", {"I", "001000", ""}}, {"andi", {"I", "001100", ""}},
    {"ori", {"I", "001101", ""}}, {"xori", {"I", "001110", ""}},
    {"lw", {"I", "100011", ""}}, {"sw", {"I", "101011", ""}},
    {"lui", {"I", "001111", ""}}, {"slti", {"I", "001010", ""}},
    {"beq",  {"I", "000100", ""}}, {"bne",  {"I", "000101", ""}},
    {"j",    {"J", "000010", ""}}, {"jal", {"J", "000011", ""}}
};

// 쉼표, 괄호 제거해서 순수 토큰만 남기기
string clean(string s) {
    s.erase(remove(s.begin(), s.end(), ','), s.end());
    s.erase(remove(s.begin(), s.end(), '('), s.end());
    s.erase(remove(s.begin(), s.end(), ')'), s.end());
    return s;
}

int main(int argc, char* argv[]) {
    if (argc != 3) 
    {
        cerr << "사용법: " << argv[0] << " input.asm output.bin" << endl;
        return 1;
    }

    ifstream fin(argv[1]);
    ofstream fout(argv[2]);

    if (!fin) 
    {
        cerr << "입력 파일을 열 수 없습니다." << endl;
        return 1;
    }
    if (!fout) 
    {
        cerr << "출력 파일을 열 수 없습니다." << endl;
        return 1;
    }

    vector<string> lines; // 주석 제거된 명령어 보관용
    map<string, int> labels; // label 주소 저장용
    string line;
    int pc = 0;

    // label 처리 
    while (getline(fin, line)) 
    {
        // 빈 줄 또는 주석 건너뛰기
        if (line.empty() || line[0] == '#') 
            continue;

        size_t comment_pos = line.find('#');

        if (comment_pos != string::npos) 
            line = line.substr(0, comment_pos);

        stringstream ss(line);
        string word;
        ss >> word;

        // 단어 끝 (:) 있으면 label로 판단
        if (word.back() == ':') 
        {
            labels[word.substr(0, word.length() - 1)] = pc;
        }
        else 
        {
            lines.push_back(line); // 실제 실행될 명령어만 벡터에 저장하기
            pc += 4; // instruction 1개당 4바이트씩 증가
        }
    }

    // bin으로 변환하고 출력하기
    pc = 0;
    for (const string& l : lines) 
    {
        stringstream ss(l);
        string op, rd, rs, rt, imm;
        ss >> op;

        // 정의 안 된 instruction은 건너뛰기
        if (inst_map.find(op) == inst_map.end())
            continue;

        InstInfo info = inst_map[op];
        string result = "";

        if (info.type == "R") 
        {
            // R포맷 -> op(6) + rs(5) + rt(5) + rd(5) + shamt(5) + funct(6)
            if (op == "jr")
            {
                ss >> rs;
                result = info.opcode + bitset<5>(reg_map[clean(rs)]).to_string()
                    + "000000000000000" + info.funct;
            }
            else if (op == "sll" || op == "srl")
            {
                int shamt;
                ss >> rd >> rt >> shamt;
                result = info.opcode + "00000"
                    + bitset<5>(reg_map[clean(rt)]).to_string()
                    + bitset<5>(reg_map[clean(rd)]).to_string()
                    + bitset<5>(shamt).to_string() + info.funct;
            }
            else
            {
                ss >> rd >> rs >> rt;
                result = info.opcode + bitset<5>(reg_map[clean(rs)]).to_string() +
                    bitset<5>(reg_map[clean(rt)]).to_string() +
                    bitset<5>(reg_map[clean(rd)]).to_string() + "00000" + info.funct;
            }
        }
        else if (info.type == "I") 
        {
            // I포맷 -> op(6) + rs(5) + rt(5) + immediate(16)
            if (op == "lw" || op == "sw") 
            {
                string temp;
                ss >> rt >> temp;
               
                size_t open_bracket = temp.find('(');
                size_t close_bracket = temp.find(')');
                string offset_str = temp.substr(0, open_bracket);
                string base_reg = temp.substr(open_bracket + 1, close_bracket - open_bracket - 1);

                result = info.opcode + bitset<5>(reg_map[clean(base_reg)]).to_string() +
                    bitset<5>(reg_map[clean(rt)]).to_string() +
                    bitset<16>(stoi(offset_str)).to_string();
            }
            else if (op == "beq" || op == "bne") 
            {
                ss >> rs >> rt >> imm;
                // Branch 주소: (타겟주소-(현재PC + 4))/4
                int offset = (labels[imm] - (pc + 4)) / 4;
                result = info.opcode + bitset<5>(reg_map[clean(rs)]).to_string() +
                    bitset<5>(reg_map[clean(rt)]).to_string() +
                    bitset<16>(offset).to_string();
            }
            else 
            {
                ss >> rt >> rs >> imm;
                result = info.opcode + bitset<5>(reg_map[clean(rs)]).to_string() +
                    bitset<5>(reg_map[clean(rt)]).to_string() +
                    bitset<16>(stoi(imm)).to_string();
            }
        }
        else if (info.type == "J") 
        {
            // J포맷 -> op(6) + target address(26)
            ss >> imm;
            result = info.opcode + bitset<26>(labels[imm] / 4).to_string();
        }

        fout << result << endl; // 결과 저장
        pc += 4;
    }
    
    

    fin.close();
    fout.close();
    return 0;
}
