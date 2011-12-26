/*
 cl /LD gvimfullscreen.c user32.lib
 ------------------------------
 :call libcallnr("gvimfullscreen.dll", "EnableFullScreen", 1)
*/
#include <windows.h>

int g_x, g_y, g_dx, g_dy;

BOOL CALLBACK EnumChildProc(HWND hwnd, LPARAM lParam);

BOOL CALLBACK FindWindowProc(HWND hwnd, LPARAM lParam)
{
    HWND* pphWnd = (HWND*)lParam;

	if (GetParent(hwnd))
	{
   		*pphWnd = NULL;
		return TRUE;
	}
   	*pphWnd = hwnd;
   	return FALSE;
}

LONG _declspec(dllexport) ToggleFullScreen()
{
	HWND hTop = NULL;
	DWORD dwThreadID;

	dwThreadID = GetCurrentThreadId();
	EnumThreadWindows(dwThreadID, FindWindowProc, (LPARAM)&hTop);

	if (hTop)
	{
		/* Determine the current state of the window */

		if ( GetWindowLong(hTop, GWL_STYLE) & WS_CAPTION )
		{
			/* Has a caption, so isn't maximised */

			MONITORINFO mi;
			RECT rc;
			HMONITOR hMonitor;

			GetWindowRect(hTop, &rc);
			hMonitor = MonitorFromRect(&rc, MONITOR_DEFAULTTONEAREST);

			// 
			// get the work area or entire monitor rect. 
			// 
			mi.cbSize = sizeof(mi);
			GetMonitorInfo(hMonitor, &mi);

			g_x = mi.rcMonitor.left;
			g_y = mi.rcMonitor.top;
			g_dx = mi.rcMonitor.right - g_x;
			g_dy = mi.rcMonitor.bottom - g_y;
			//cx = GetSystemMetrics(SM_CXSCREEN);
			//cy = GetSystemMetrics(SM_CYSCREEN);

			/* Remove border, caption, and edges */
			SetWindowLong(hTop, GWL_STYLE, GetWindowLong(hTop, GWL_EXSTYLE) & ~WS_BORDER); 
			SetWindowLong(hTop, GWL_STYLE, GetWindowLong(hTop, GWL_STYLE) & ~WS_CAPTION); 
			SetWindowLong(hTop, GWL_EXSTYLE, GetWindowLong(hTop, GWL_STYLE) & ~WS_EX_CLIENTEDGE); 
			SetWindowLong(hTop, GWL_EXSTYLE, GetWindowLong(hTop, GWL_STYLE) & ~WS_EX_WINDOWEDGE); 

			SetWindowPos(hTop, HWND_TOP, g_x, g_y, g_dx, g_dy, SWP_SHOWWINDOW);

			/* Now need to find the child text area window 
			 * and set it's size accordingly 
			 */
			EnumChildWindows(hTop, EnumChildProc, 0);
		}
		else
		{
			/* Already full screen, so restore all the previous styles */
			SetWindowLong(hTop, GWL_EXSTYLE, GetWindowLong(hTop, GWL_EXSTYLE) | WS_BORDER); 
			SetWindowLong(hTop, GWL_STYLE, GetWindowLong(hTop, GWL_STYLE) | WS_CAPTION); 
			SetWindowLong(hTop, GWL_STYLE, GetWindowLong(hTop, GWL_STYLE) | WS_SYSMENU); 
			SetWindowLong(hTop, GWL_STYLE, GetWindowLong(hTop, GWL_STYLE) | WS_MINIMIZEBOX); 
			SetWindowLong(hTop, GWL_STYLE, GetWindowLong(hTop, GWL_STYLE) | WS_MAXIMIZEBOX); 
			SetWindowLong(hTop, GWL_STYLE, GetWindowLong(hTop, GWL_STYLE) | WS_SYSMENU); 
			SetWindowLong(hTop, GWL_STYLE, GetWindowLong(hTop, GWL_STYLE) | WS_EX_CLIENTEDGE); 
			SetWindowLong(hTop, GWL_STYLE, GetWindowLong(hTop, GWL_STYLE) | WS_EX_WINDOWEDGE); 
			SetWindowLong(hTop, GWL_STYLE, GetWindowLong(hTop, GWL_STYLE) | WS_THICKFRAME); 
			SetWindowLong(hTop, GWL_STYLE, GetWindowLong(hTop, GWL_STYLE) | WS_DLGFRAME); 


			SendMessage(hTop, WM_SYSCOMMAND, SC_RESTORE, 0);
			SendMessage(hTop, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
		}
	}
	return GetLastError();
}

BOOL CALLBACK EnumChildProc(HWND hwnd, LPARAM lParam)
{
	char lpszClassName[100];
	GetClassName(hwnd, lpszClassName, 100);
	if ( strcmp(lpszClassName, "VimTextArea") == 0 ) 
	{
		//int cx, cy;
		//cx = GetSystemMetrics(SM_CXSCREEN);
		//cy = GetSystemMetrics(SM_CYSCREEN);

		SetWindowLong(hwnd, GWL_EXSTYLE, GetWindowLong(hwnd, GWL_STYLE) & ~WS_EX_CLIENTEDGE); 
		SetWindowLong(hwnd, GWL_EXSTYLE, GetWindowLong(hwnd, GWL_STYLE) & ~WS_EX_WINDOWEDGE); 
		SetWindowPos(hwnd, HWND_TOP, 0, 0, g_dx, g_dy, SWP_SHOWWINDOW);

        SetClassLong(hwnd, GCL_HBRBACKGROUND, CreateSolidBrush(RGB(0,0,0)));
	}
	return TRUE;
	
}
