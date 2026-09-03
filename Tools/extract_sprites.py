#!/usr/bin/env python3
import os
import collections
from PIL import Image

def make_transparent(im, white_thresh=210):
    im = im.convert('RGBA')
    w, h = im.size
    pixels = im.load()
    visited = [[False]*h for _ in range(w)]
    queue = collections.deque()

    def is_bg(r, g, b, a):
        return (r > white_thresh and g > white_thresh and b > white_thresh)

    # Seed borders
    for x in range(w):
        for y in [0, 1, h-2, h-1]:
            r, g, b, a = pixels[x, y]
            if is_bg(r, g, b, a) or (r < 15 and g < 15 and b < 15):
                queue.append((x, y))
                visited[x][y] = True

    for y in range(h):
        for x in [0, 1, w-2, w-1]:
            if not visited[x][y]:
                r, g, b, a = pixels[x, y]
                if is_bg(r, g, b, a) or (r < 15 and g < 15 and b < 15):
                    queue.append((x, y))
                    visited[x][y] = True

    # Seed interior grid lines
    for x in range(0, w, 15):
        for y in range(0, h, 15):
            if not visited[x][y]:
                r, g, b, a = pixels[x, y]
                if r > 242 and g > 242 and b > 242:
                    queue.append((x, y))
                    visited[x][y] = True

    while queue:
        cx, cy = queue.popleft()
        pixels[cx, cy] = (0, 0, 0, 0)
        for dx, dy in [(-1,0), (1,0), (0,-1), (0,1)]:
            nx, ny = cx + dx, cy + dy
            if 0 <= nx < w and 0 <= ny < h and not visited[nx][ny]:
                r, g, b, a = pixels[nx, ny]
                if is_bg(r, g, b, a):
                    visited[nx][ny] = True
                    queue.append((nx, ny))

    return im

def extract_frames_by_columns(im, x0, y0, x1, y1, num_frames, out_dir, prefix):
    os.makedirs(out_dir, exist_ok=True)
    crop = im.crop((x0, y0, x1, y1))
    w, h = crop.size
    frame_w = w / float(num_frames)
    
    saved_paths = []
    for i in range(num_frames):
        fx0 = max(0, int(round(i * frame_w)))
        fx1 = min(w, int(round((i + 1) * frame_w)))
        frame = crop.crop((fx0, 0, fx1, h))
        
        # Clean small artifacts on borders
        bbox = frame.getbbox()
        if bbox:
            cropped = frame.crop(bbox)
            size = max(cropped.width, cropped.height) + 12
            canvas = Image.new('RGBA', (size, size), (0, 0, 0, 0))
            canvas.paste(cropped, ((size - cropped.width)//2, (size - cropped.height)//2))
            out_file = os.path.join(out_dir, f"{prefix}_{i}.png")
            canvas.save(out_file)
            saved_paths.append(out_file)
        else:
            out_file = os.path.join(out_dir, f"{prefix}_{i}.png")
            frame.save(out_file)
            saved_paths.append(out_file)

    print(f"Extracted {len(saved_paths)} frames for {prefix} to {out_dir}")
    return saved_paths

def run():
    print("1. Processing Rabbit...")
    r_img = Image.open('assets/spritesheets/rabbit.png')
    r_trans = make_transparent(r_img)
    r_trans.save('assets/spritesheets/rabbit_transparent.png')

    h_dir = 'assets/spritesheets/hare'
    extract_frames_by_columns(r_trans, 5, 20, 480, 120, 6, f"{h_dir}/idle", "hare_idle")
    extract_frames_by_columns(r_trans, 5, 156, 480, 240, 8, f"{h_dir}/run", "hare_run")
    extract_frames_by_columns(r_trans, 5, 270, 480, 360, 6, f"{h_dir}/happy", "hare_happy")
    extract_frames_by_columns(r_trans, 0, 390, 480, 455, 6, f"{h_dir}/sleep", "hare_sleep")

    extract_frames_by_columns(r_trans, 505, 20, 1010, 115, 8, f"{h_dir}/walk", "hare_walk")
    extract_frames_by_columns(r_trans, 520, 380, 1000, 460, 5, f"{h_dir}/surprised", "hare_surprised")
    extract_frames_by_columns(r_trans, 505, 480, 1010, 568, 6, f"{h_dir}/cheer", "hare_cheer")

    print("2. Processing Turtle...")
    t_img = Image.open('assets/spritesheets/turtle.png')
    t_trans = make_transparent(t_img)
    t_trans.save('assets/spritesheets/turtle_transparent.png')

    t_dir = 'assets/spritesheets/tortoise'
    extract_frames_by_columns(t_trans, 15, 25, 1150, 110, 8, f"{t_dir}/idle", "tortoise_idle")
    extract_frames_by_columns(t_trans, 15, 135, 1150, 220, 8, f"{t_dir}/walk", "tortoise_walk")
    extract_frames_by_columns(t_trans, 15, 250, 1150, 335, 8, f"{t_dir}/run", "tortoise_run")
    extract_frames_by_columns(t_trans, 15, 475, 580, 555, 6, f"{t_dir}/sleep", "tortoise_sleep")
    extract_frames_by_columns(t_trans, 530, 585, 1150, 665, 6, f"{t_dir}/climb", "tortoise_climb")
    # Win / Finish with red ribbon: 5 complete frames across x=560 to 1135, y=675 to 765
    ranges = [(560, 675), (675, 780), (780, 885), (885, 990), (990, 1135)]
    os.makedirs(f"{t_dir}/win", exist_ok=True)
    for i, (x0, x1) in enumerate(ranges):
        crop = t_trans.crop((x0, 675, x1, 765))
        bbox = crop.getbbox()
        if bbox:
            c = crop.crop(bbox)
            sz = max(c.width, c.height) + 12
            canv = Image.new('RGBA', (sz, sz), (0,0,0,0))
            canv.paste(c, ((sz-c.width)//2, (sz-c.height)//2))
            canv.save(f"{t_dir}/win/tortoise_win_{i}.png")

    print("3. Processing Badges...")
    b_dir = 'assets/spritesheets/badges'
    os.makedirs(b_dir, exist_ok=True)
    for bname in ['emrald_badge.png', 'blue_badge.png', 'safron_badge.png']:
        bpath = f'assets/spritesheets/{bname}'
        if os.path.exists(bpath):
            bim = Image.open(bpath)
            cw, ch = bim.width / 10.0, bim.height / 6.0
            # Idle glowing frame
            f_idle = bim.crop((int(cw * 4), 0, int(cw * 5), int(ch)))
            # Sparkle burst frame (Row 4, Col 5)
            f_win = bim.crop((int(cw * 5), int(ch * 4), int(cw * 6), int(ch * 5)))
            
            clean = bname.replace('.png', '')
            f_idle.save(f"{b_dir}/{clean}_idle.png")
            f_win.save(f"{b_dir}/{clean}_win.png")
            print(f"Saved badges for {bname}")

if __name__ == '__main__':
    run()
