import re
import sys

def time_to_seconds(time_str):
    """Convert HH:MM:SS.sss or MM:SS.sss to seconds."""
    time_str = time_str.replace(',', '.')
    parts = time_str.split(':')
    if len(parts) == 3:
        h, m, s = parts
        return int(h) * 3600 + int(m) * 60 + float(s)
    elif len(parts) == 2:
        m, s = parts
        return int(m) * 60 + float(s)
    return float(time_str)

def seconds_to_time(seconds):
    """Convert seconds to HH:MM:SS.sss format."""
    hours = int(seconds // 3600)
    seconds %= 3600
    minutes = int(seconds // 60)
    seconds = seconds % 60
    return f"{hours:02d}:{minutes:02d}:{seconds:06.3f}"

def filter_vtt(input_vtt, output_vtt, start_time, end_time, reset_to_zero=False):
    """Filter .vtt subtitles between start_time and end_time, optionally resetting timestamps to 00:00."""
    start_secs = time_to_seconds(start_time)
    end_secs = time_to_seconds(end_time)
    
    with open(input_vtt, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    with open(output_vtt, 'w', encoding='utf-8') as f:
        f.write("WEBVTT\n\n")
        i = 0
        while i < len(lines):
            if '-->' in lines[i] and re.match(r'^\d{2}:\d{2}:\d{2}\.\d{3}\s-->\s\d{2}:\d{2}:\d{2}\.\d{3}$', lines[i].strip()):
                times = lines[i].strip().split(' --> ')
                start = time_to_seconds(times[0])
                end = time_to_seconds(times[1])
                
                if start_secs <= start <= end_secs:
                    if reset_to_zero:
                        new_start = start - start_secs
                        new_end = end - start_secs
                        if new_start >= 0:
                            f.write(f"{seconds_to_time(new_start)} --> {seconds_to_time(new_end)}\n")
                    else:
                        f.write(lines[i])
                    i += 1
                    while i < len(lines) and lines[i].strip() and '-->' not in lines[i]:
                        f.write(lines[i])
                        i += 1
                    f.write('\n')
                else:
                    i += 1
            else:
                i += 1

if __name__ == "__main__":
    if len(sys.argv) != 6:
        print("Usage: python filter_vtt.py input_vtt output_vtt start_time end_time reset_to_zero")
        sys.exit(1)
    input_vtt, output_vtt, start_time, end_time, reset_to_zero = sys.argv[1:6]
    reset_to_zero = reset_to_zero.lower() == "true"
    filter_vtt(input_vtt, output_vtt, start_time, end_time, reset_to_zero)