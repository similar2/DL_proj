#include <iostream>
#include <windows.h>
#include <string>
#include <thread>
using namespace std;

#define DATASIZE 1
#define BIT 8

void PrintFeedBackData(unsigned char FeedBackInfo)
{
    cout << "Send FeedBack Data: ";
    for (int i = 0; i < 4; i++)
    {
        cout << ((FeedBackInfo >> (3 - i)) & 1);
    }
    cout << '\n';
}

int main(int argc, char **argv)
{
    int millisecond = 500;
    if (argc == 2)
    {
        millisecond = stoi(argv[1]);
    }
    HANDLE hSerial = CreateFileA("COM4", GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL);
    if (hSerial == INVALID_HANDLE_VALUE)
    {
        cerr << "Failed to open the serial port." << endl;
        return 1;
    }

    COMMTIMEOUTS timeouts = {0};
    if (!GetCommTimeouts(hSerial, &timeouts))
    {
        cerr << "Error getting serial port timeouts!" << endl;
        CloseHandle(hSerial);
        return 1;
    }

    timeouts.ReadIntervalTimeout = 0;

    if (!SetCommTimeouts(hSerial, &timeouts))
    {
        cerr << "Error setting serial port timeouts!" << endl;
        CloseHandle(hSerial);
        return 1;
    }

    DCB dcbSerialParams = {0};
    dcbSerialParams.DCBlength = sizeof(dcbSerialParams);

    if (!GetCommState(hSerial, &dcbSerialParams))
    {
        cerr << "Failed to get COM port parameters." << endl;
        CloseHandle(hSerial);
        return 1;
    }

    dcbSerialParams.BaudRate = CBR_9600;   // 设置波特率
    dcbSerialParams.ByteSize = 8;          // 数据位
    dcbSerialParams.StopBits = ONESTOPBIT; // 停止位
    dcbSerialParams.Parity = NOPARITY;     // 无校验位

    if (!SetCommState(hSerial, &dcbSerialParams))
    {
        cerr << "Failed to set COM port parameters." << endl;
        CloseHandle(hSerial);
        return 1;
    }

    DWORD bytesWritten = 0;
    unsigned char SendData = 0;
    unsigned char FeedBackInfo = 0;
    for (int i = 0; i < 15; i++)
    {
        this_thread::sleep_for(chrono::milliseconds(millisecond));
        SendData = 1;
        SendData |= (FeedBackInfo << 2);
        PrintFeedBackData(FeedBackInfo++);
        WriteFile(hSerial, &SendData, DATASIZE, &bytesWritten, NULL);
    }

    CloseHandle(hSerial);
    return 0;
}