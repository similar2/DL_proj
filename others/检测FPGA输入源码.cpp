#include <iostream>
#include <windows.h>
#include <string>
#include <unordered_map>
using namespace std;

#define DATASIZE 1
#define BIT 8

bool DiffArray(bool *array1, bool *array2, int length)
{
    for (int i = 0; i < length; i++)
    {
        if (array1[i] != array2[i])
            return true;
    }
    return false;
}

void CopyArray(bool *src, bool *dst, int length)
{
    for (int i = 0; i < length; i++)
        dst[i] = src[i];
}

void PrintArrayReverse(bool *array, int length)
{
    for (int i = 0; i < length; i++)
    {
        cout << array[length - 1 - i];
    }
    cout << endl;
}

string ByteToOrder(char data)
{
    bool b[BIT]{0};
    for (int i = 0; i < BIT; i++)
        b[i] = ((data >> i) & 1);
    string ret;
    if (!b[1] && b[0])
    {
        ret.append("Game State Control -- ");
        if (!b[3] && b[2])
            ret.append("Start Game");
        else if (b[3] && !b[2])
            ret.append("Stop Game");
        else
            ret.append("Ignored");
    }
    else if (b[1] && !b[0])
    {
        ret.append("Traveler Operating Machine -- ");
        if (!b[6] && !b[5] && !b[4] && !b[3] && b[2])
            ret.append("Get");
        else if (!b[6] && !b[5] && !b[4] && b[3] && !b[2])
            ret.append("Put");
        else if (!b[6] && !b[5] && b[4] && !b[3] && !b[2])
            ret.append("Interact");
        else if (!b[6] && b[5] && !b[4] && !b[3] && !b[2])
            ret.append("Move");
        else if (b[6] && !b[5] && !b[4] && !b[3] && !b[2])
            ret.append("Throw");
        else if (!b[6] && !b[5] && !b[4] && !b[3] && b[2])
            ret.append("Ignored");
        else
            ret.append("ERROR!!!!!");
    }
    else if (b[1] && b[0])
    {
        int target = 0;
        ret.append("Traveler Targeting Machine -- ");
        for (int i = 0; i < 6; i++)
        {
            if (b[i + 2] == 1)
                target |= (1 << i);
        }
        ret.append("Move to ").append(to_string(target));
    }
    else
    {
        ret.append("Ignored by Client");
    }
    return ret;
}

int main()
{
    HANDLE hSerial = CreateFileA("COM4", GENERIC_READ, 0, NULL, OPEN_EXISTING, 0, NULL);
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

    char receiveData = 0;
    DWORD bytesRead = 0;

    while (true)
    {
        if (ReadFile(hSerial, &receiveData, DATASIZE, &bytesRead, NULL))
        {
            if (bytesRead == DATASIZE)
            {
                cout << "Receive: ";
                for (int j = 0; j < BIT; j++)
                {
                    cout << ((receiveData >> BIT - 1 - j) & 1);
                }
                cout << "  ->  " << ByteToOrder(receiveData) << endl;
            }
            else
            {
                if (bytesRead == 0)
                    cerr << "Error recving data of datasize :" << bytesRead << endl;
            }
        }
        else
        {
            cerr << "Error reading from serial port." << endl;
            return 1;
        }
    }
    CloseHandle(hSerial);
    return 0;
}